#! /usr/bin/env ruby
#
# check-dcos-component-health
#
# DESCRIPTION:
#    This plugin checks the health of a DC/OS components exposed by the system/health/v1/units API endpoint
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
#    check-dcos-component-health.rb -u 'http://127.0.0.1:1050/system/health/v1/units' -c 'exhibitor.service'
#
#    You can also run an ultimate health report to see if there are nay filing units::
#    check-dcos-component-health.rb -u 'http://127.0.0.1:1050/system/health/v1/units'
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

class CheckDcosComponentHealth < Sensu::Plugin::Check::CLI
  include Common

  option :url,
         description: 'URL',
         short: '-u URL',
         long: '--url URL',
         default: 'http://127.0.0.1:1050/system/health/v1/units'

  option :component,
         description: 'Component ID',
         short: '-c COMPONENT',
         long: '--component COMPONENT',
         default: nil

  option :filter,
         description: 'Filter by Tags',
         short: '-f TAG_NAME:TAG_VALUE',
         long: '--filter TAG_NAME:TAG_VALUE',
         default: nil

  def run
    if config[:component]
      value = get_value(config[:url], config[:component], config[:filter], 'id', 'health', 'units')
      message "#{config[:component]} = #{value}"
      if value.zero?
        ok
      else
        critical
      end
    else
      failed = 0
      resource = get_data(config[:url])
      resource['units'].each do |unit|
        failed += unit['health']
      end
      message "components.unhealthy = #{failed}"
      if failed.zero?
        ok
      else
        critical
      end
    end
  end
end
