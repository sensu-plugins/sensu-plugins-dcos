#! /usr/bin/env ruby
#
# check-dcos-metrics
#
# DESCRIPTION:
#    This plugin checks the value of a metric exposed by the dcos-metrics API across all running containers
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
#    This example checks if the container is being throttled
#    check-dcos-container-metrics.rb -m 'cpus.throttled.time' -W 10 -C 20
#
# NOTES:
#   TODO: investigate https://github.com/thirtysixthspan/descriptive_statistics to have more options for mode
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

class CheckDcosContainersApi < Sensu::Plugin::Check::CLI
  include Common

  option :url,
         description: 'URL',
         short: '-u URL',
         long: '--url URL',
         default: 'http://127.0.0.1:61001/system/v1/metrics/v0/containers'

  option :metric,
         description: 'Metric Name',
         short: '-m METRIC',
         long: '--metric METRIC',
         default: 'foo'

  option :mode,
         description: 'min max or avg',
         short: '-M MODE',
         long: '--mode MODE',
         default: 'avg'

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
    mode = config[:mode]
    value = ['all containers', -1]
    data = {}
    if config[:delta]
      db = Daybreak::DB.new '/tmp/dcos-metrics.db', default: 0
    end
    containers = get_data(config[:url])
    unless containers.nil? || containers.empty?
      containers.each do |container|
        v = get_value("#{config[:url]}/#{container}", config[:metric], config[:filter])
        if config[:delta]
          prev_value = db["#{container}_#{config[:metric]}"]
          db.lock do
            db["#{container}_#{config[:metric]}"] = v
          end
          v -= prev_value
        end
        data[container] = v
      end
    end
    if config[:delta]
      db.flush
      db.compact
      db.close
    end
    if data.empty?
      ok 'No containers found'
    end
    case mode
    when 'min'
      value = data.min_by { |_k, v| v }
    when 'max'
      value = data.max_by { |_k, v| v }
    when 'avg'
      value[1] = data.values.inject(:+).to_f / data.length
    end
    message "#{mode} #{config[:metric]} = #{value[1]} on #{value[0]}"
    if value[1] >= config[:crithigh] || value[1] <= config[:critlow]
      critical
    elsif value[1] >= config[:warnhigh] || value[1] <= config[:warnlow]
      warning
    else
      ok
    end
  end
end
