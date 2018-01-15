#! /usr/bin/env ruby
# frozen_string_literal: true

#
# check-dcos-node-health
#
# DESCRIPTION:
#    This plugin checks the health of a DC/OS nodes exposed by the system/health/v1/nodes API endpoint
#
# OUTPUT:
#    Plain text
#
# PLATFORMS:
#    Linux
#
# DEPENDENCIES:
#    gem: sensu-plugin
#
# USAGE:
#    check-dcos-node-health.rb -u 'http://127.0.0.1:1050/system/health/v1/nodes' -r [master|agent]
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
require 'sensu-plugins-dcos'

#
# Check DCOS System Health API
#

class CheckDcosNodeHealth < Sensu::Plugin::Check::CLI
  include Common

  option :url,
         description: 'URL',
         short: '-u URL',
         long: '--url URL',
         default: 'http://127.0.0.1:1050/system/health/v1/nodes'

  option :role,
         description: 'DC/OS Role',
         short: '-r ROLE',
         long: '--role ROLE',
         default: nil

  def run
    failed = 0
    resource = get_data(config[:url])
    if config[:role]
      resource['nodes'].each do |node|
        node['role'] == config[:role] && failed += node['health']
      end
      message "#{config[:role]}.nodes.unhealthy = #{failed}"
    else
      resource['nodes'].each do |node|
        failed += node['health']
      end
      message "nodes.unhealthy = #{failed}"
    end
    if failed.zero?
      ok
    else
      critical
    end
  end
end
