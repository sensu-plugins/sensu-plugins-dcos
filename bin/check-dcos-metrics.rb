#! /usr/bin/env ruby
# frozen_string_literal: true

#
# check-dcos-metrics
#
# DESCRIPTION:
#    This plugin checks the value of a metric exposed by the dcos-metrics API
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
#    This example checks that the count of running processes is between 150 and 300
#       a warning message will be triggered if the count is below 150 or above 300
#       a critical message will be triggered if the count is below 100 or above 350
#    check-dcos-metrics.rb -u 'http://127.0.0.1:61001/system/v1/metrics/v0/node' -m 'process.count' -w 150 -c
#    100 -W 300 -C 350
#
#    You can also filter metrics by tags using the --filter option followed by TAG_NAME:TAG_VALUE
#    check-dcos-metrics.rb -m 'network.in.errors' -f interface:docker0 -C 2 -W 1
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
require 'daybreak'
require 'sensu-plugins-dcos'

#
# Check DCOS API
#

class CheckDcosApi < Sensu::Plugin::Check::CLI
  include Common

  option :url,
         description: 'URL',
         short: '-u URL',
         long: '--url URL',
         default: 'http://127.0.0.1:61001/system/v1/metrics/v0/node'

  option :metric,
         description: 'Metric Name',
         short: '-m METRIC',
         long: '--metric METRIC',
         default: 'foo'

  option :filter,
         description: 'Filter by Tags',
         short: '-f TAG_NAME:TAG_VALUE',
         long: '--filter TAG_NAME:TAG_VALUE',
         default: nil

  option :warnhigh,
         short: '-W N',
         long: '--warnhigh N',
         description: 'WARNING HIGH threshold',
         proc: proc(&:to_i),
         default: 5000

  option :crithigh,
         short: '-C N',
         long: '--crithigh N',
         description: 'CRITICAL HIGH threshold',
         proc: proc(&:to_i),
         default: 9000

  option :warnlow,
         short: '-w N',
         long: '--warnlow N',
         description: 'WARNING LOW threshold',
         proc: proc(&:to_i),
         default: -1

  option :critlow,
         short: '-c N',
         long: '--critlow N',
         description: 'CRITICAL LOW threshold',
         proc: proc(&:to_i),
         default: -1

  option :delta,
         short: '-d',
         long: '--delta',
         description: 'Use this flag to compare the metric with the previously retreived value',
         boolean: true

  def run
    value = get_value(config[:url], config[:metric], config[:filter])
    if config[:delta]
      db = Daybreak::DB.new '/tmp/dcos-metrics.db', default: 0
      prev_value = db["node_#{config[:metric]}"]
      db.lock do
        db["node_#{config[:metric]}"] = value
      end
      value -= prev_value
      db.flush
      db.compact
      db.close
    end
    message "#{config[:metric]} = #{value}"
    if value >= config[:crithigh] || value <= config[:critlow]
      critical
    elsif value >= config[:warnhigh] || value <= config[:warnlow]
      warning
    else
      ok
    end
  end
end
