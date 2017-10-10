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

  def run
    containers = get_data("http://#{config[:server]}:#{config[:port]}#{config[:uri]}")
    unless containers.nil? || containers.empty?
      containers.each do |container| # rubocop:disable Metrics/BlockLength
        all_metrics = get_data("http://#{config[:server]}:#{config[:port]}#{config[:uri]}/#{container}")
        if config[:dimensions]
          extra_tags = []
          config[:dimensions].tr(' ', '').split(',').each do |d|
            extra_tags.push(all_metrics['dimensions'][d]) if all_metrics['dimensions'][d]
          end
        end
        if all_metrics.key?('datapoints')
          all_metrics['datapoints'].each do |metric|
            metric['name'].tr!('/', '.')
            metric['name'].squeeze!('.')
            output([config[:scheme], extra_tags, container, metric['unit'], metric['name']].compact.join('.'), metric['value'])
          end
        end
        app_metrics = get_data("http://#{config[:server]}:#{config[:port]}#{config[:uri]}/#{container}/app")
        next if app_metrics['datapoints'].nil?
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
