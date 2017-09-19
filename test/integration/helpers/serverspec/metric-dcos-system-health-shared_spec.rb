# frozen_string_literal: true

require 'spec_helper'
require 'shared_spec'

gem_path = '/usr/local/bin'
check_name = 'metrics-dcos-system-health.rb'
check = "#{gem_path}/#{check_name}"

describe 'ruby environment' do
  it_behaves_like 'ruby checks', check
end

describe command("#{check} -s dcos.health -u http://localhost/system/health") do
  its(:exit_status) { should eq 0 }
  pattern = 'dcos\.health\.units\.dcos-mesos-slave-public-service 0 \d{10}\n'\
           'dcos\.health\.units\.dcos-log-master-socket 0 \d{10}\n'\
           'dcos\.health\.units\.dcos-metrics-master-socket 0 \d{10}\n'\
           'dcos\.health\.units\.dcos-3dt-socket 0 \d{10}\n'\
           'dcos\.health\.nodes\.agent\.10-0-3-118 0 \d{10}\n'\
           'dcos\.health\.nodes\.agent\.10-0-3-25 0 \d{10}\n'\
           'dcos\.health\.nodes\.agent\.10-0-3-245 0 \d{10}\n'\
           'dcos\.health\.nodes\.agent\.10-0-3-201 0 \d{10}\n'\
           'dcos\.health\.nodes\.master\.10-0-1-39 0 \d{10}'
  its(:stdout) { should match(Regexp.new(pattern)) }
end
