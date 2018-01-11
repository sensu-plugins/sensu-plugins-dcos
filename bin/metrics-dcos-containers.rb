#! /usr/bin/env ruby
#
#   dcos-metrics
#
# DESCRIPTION:
#   This plugin extracts the container metrics from a dcos server
#
# OUTPUT:
#    metric data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: uri
#   gem: net/http
#   gem: socket
#   gem: json
#
# USAGE:
#   #YELLOW
#
# NOTES:
#
# LICENCE:
#    PTC http://www.ptc.com/
#    Copyright 2017 PTC Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

require 'sensu-plugin/metric/cli'
require 'json'
require 'net/http'
require 'uri'
require 'socket'
require 'sensu-plugins-dcos'

class DCOSMetrics < Sensu::Plugin::Metric::CLI::Graphite
  include Common

  option :scheme,
         description: 'Metric naming scheme',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.dcos.container"

  option :server,
         description: 'DCOS Host',
         short: '-h SERVER',
         long: '--host SERVER',
         default: 'localhost'

  option :port,
         description: 'DCOS-metrics port',
         short: '-p PORT',
         long: '--port PORT',
         required: false,
         default: '61001'

  option :agent_ip_discovery_command,
         description: 'DCOS agent ip discovery command',
         long: '--agent-ip-discovery-command COMMAND',
         required: false,
         default: '/opt/mesosphere/bin/detect_ip'

  option :agent_port,
         description: 'DCOS agent port',
         long: '--agent-port PORT',
         required: false,
         default: '5051'

  option :uri,
         description: 'Endpoint URI',
         short: '-u URI',
         long: '--uri URI',
         default: '/system/v1/metrics/v0/containers'

  option :dimensions,
         description: 'comma seperated list of dimensions to add into the output',
         short: '-d DIMENSIONS',
         long: '--dimensions DIMENSIONS',
         required: false

  def frameworks
    # Return the memoized result if exists. This will ensure that the mesos
    # state endpoint will be called only once and when needed and return the
    # cached result immediately for subsequent calls.
    return @frameworks if @frameworks
    agent_ip = `#{config[:agent_ip_discovery_command]}`
    state = get_data("http://#{agent_ip}:#{config[:agent_port]}/slave(1)/state")
    @frameworks = {}
    %w[frameworks completed_frameworks].each do |fw_key|
      state[fw_key].each do |framework|
        @frameworks[framework['id']] = framework['name']
      end
    end
    @frameworks
  end

  def get_extra_tags(dimensions)
    extra_tags = []
    return extra_tags unless config[:dimensions]
    config[:dimensions].tr(' ', '').split(',').each do |d|
      # Special case for app metrics, framework_name dimension does not exist
      # in app metrics and in some cases app metrics/dimensions are not
      # available, see https://jira.mesosphere.com/browse/DCOS_OSS-2043 for
      # upstream issue.
      if d == 'framework_name' && !dimensions.key?('framework_name')
        extra_tags.push(frameworks[dimensions['framework_id']])
      else
        extra_tags.push(dimensions[d])
      end
    end
    extra_tags
  end

  def run
    containers = get_data("http://#{config[:server]}:#{config[:port]}#{config[:uri]}")
    unless containers.nil? || containers.empty?
      containers.each do |container|
        container_metrics = get_data("http://#{config[:server]}:#{config[:port]}#{config[:uri]}/#{container}")
        if container_metrics.key?('datapoints')
          extra_tags = get_extra_tags(container_metrics['dimensions'])
          container_metrics['datapoints'].each do |metric|
            metric['name'].tr!('/', '.')
            metric['name'].squeeze!('.')
            output([config[:scheme], extra_tags, container, metric['unit'], metric['name']].compact.join('.'), metric['value'])
          end
        end
        app_metrics = get_data("http://#{config[:server]}:#{config[:port]}#{config[:uri]}/#{container}/app")
        next if app_metrics['datapoints'].nil?
        app_dimensions = app_metrics['dimensions']
        # merge container dimensions into app dimensions since app dimensions does have less
        app_dimensions = container_metrics['dimensions'].merge(app_dimensions) if container_metrics.key?('dimensions')
        extra_tags = get_extra_tags(app_dimensions)
        app_metrics['datapoints'].each do |metric|
          unless metric['tags'].nil?
            metric['tags'].each do |k, v|
              metric['name'] = [metric['name'], k, v].join('.')
            end
          end
          metric['name'].tr!('/', '.')
          metric['name'].squeeze!('.')
          metric['unit'] = 'na' if metric['unit'].empty?
          output([config[:scheme], extra_tags, container, 'app', metric['unit'], metric['name']].compact.join('.'), metric['value'])
        end
      end
    end
    ok
  end
end
