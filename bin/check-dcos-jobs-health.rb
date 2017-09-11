#! /usr/bin/env ruby
#
# check-dcos-jobs-health
#
# DESCRIPTION:
#    This plugin checks the health of a DC/OS jobs exposed by the mesos API endpoint /tasks
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
#    check-dcos-jobs-health.rb -u 'http://leader.mesos:5050/tasks' -p 'cron.jobname' -w 1000.0000
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

class CheckDcosJobsHealth < Sensu::Plugin::Check::CLI
  include Common

  option :url,
         description: 'URL',
         short: '-u URL',
         long: '--url URL',
         default: 'http://leader.mesos:5050/tasks'

  option :pattern,
         description: 'Pattern',
         short: '-p pattern',
         long: '--pattern PATTERN',
         default: 'cron'

  option :window,
         description: 'Window/history for tasks',
         short: '-w time',
         long: '--window time',
         default: 1000.0000

  option :threshold,
         description: 'Threshold for a running task - the Window',
         short: '-t float',
         long: '--threshold float',
         default: 200.0000

  def run
    t = Time.now.to_f.round(4)
    resource = get_data(config[:url])
    resource['tasks'].each do |unit|
      if unit['id'] =~ /#{config[:pattern].sub('.', '.*')}/ && unit['statuses'][0]['timestamp'] > t - config[:window].to_f.round(4)
        if unit['state'] =~ /RUNNING/
          if t - unit['statuses'][0]['timestamp'] > (config[:window].to_f.round(4) - config[:threshold].to_f.round(4))
            message "JOB: #{unit['id']} is taking too long to finish..."
            critical
          end
        elsif unit['state'] =~ /FAILED|KILLED/
          message "JOB: #{unit['id']}"
          critical
        end
      end
    end
    ok
  end
end
