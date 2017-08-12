#! /usr/bin/env ruby
# frozen_string_literal: true

#
#   dcos-metrics
#
# DESCRIPTION:
#   This plugin extracts the metrics from a dcos server
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
         default: "#{Socket.gethostname}.dcos"

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
         default: '/system/v1/metrics/v0/node'

  def run
    all_metrics = get_data("http://#{config[:server]}:#{config[:port]}#{config[:uri]}")
    if all_metrics.key?('datapoints')
      all_metrics['datapoints'].each do |metric|
        if metric.key?('tags')
          metric['tags'].each do |k, v|
            metric['name'] = [metric['name'], k, v].join('.')
          end
        end
        metric['name'].tr!('/', '.')
        metric['name'].squeeze!('.')
        metric['unit'] = 'na' if metric['unit'].empty?
        output([config[:scheme], metric['unit'], metric['name']].join('.'), metric['value'])
      end
    end
    ok
  end
end
