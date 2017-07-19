#! /usr/bin/env ruby
#
# check-dcos-ping
#
# DESCRIPTION:
#    This plugin checks the status of a DCOS host using the /ping entrypoint from the dcos-metrics API
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
#    This example checks if the host is reporting himself as healthy
#    check-dcos-ping.rb -u 'http://127.0.0.1:61001/system/v1/metrics/v0/ping'
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
# Check DCOS API
#

class CheckDcosPing < Sensu::Plugin::Check::CLI
  include Common

  option :url,
         description: 'URL',
         short: '-u URL',
         long: '--url URL',
         default: 'http://127.0.0.1:61001/system/v1/metrics/v0/ping'

  def run
    value = get_data(config[:url])['ok']
    if value == true
      ok 'PONG'
    else
      critical "ping returned: #{value}"
    end
  end
end
