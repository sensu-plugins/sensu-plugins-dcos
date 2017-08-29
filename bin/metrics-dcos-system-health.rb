#! /usr/bin/env ruby
#
# metric-dcos-system-health
#
# DESCRIPTION:
#    This plugin collects DC/OS system health status as metric exposed by the system/health/v1/[units|nodes] API endpoints
#
# OUTPUT:
#    Metric data
#
# PLATFORMS:
#    Linux
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

require 'sensu-plugin/check/cli'
require 'json'
require 'net/http'
require 'uri'
require 'socket'
require 'sensu-plugins-dcos'

class DcosHealthMetrics < Sensu::Plugin::Metric::CLI::Graphite
  include Common

  option :scheme,
         description: 'Metric naming scheme',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.dcos.health"

  option :url,
         description: 'URL',
         short: '-u URL',
         long: '--url URL',
         default: 'http://127.0.0.1:1050/system/health/v1'

  def run
    { units: ['id'], nodes: %w[role host_ip] }.each do |endpoint, attributes|
      url = "#{config['url']}/#{endpoint}"
      resource = get_data(url)
      resource[endpoint].each do |item|
        path = attributes.map { |attr| item[attr].tr('.', '-') }.join('.')
        output([config[:scheme], endpoint, path].join('.'), item['health'])
      end
    end
  end
end
