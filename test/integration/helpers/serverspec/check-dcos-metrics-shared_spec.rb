# frozen_string_literal: true

require 'spec_helper'
require 'shared_spec'

gem_path = '/usr/local/bin'
check_name = 'check-dcos-metrics.rb'
check = "#{gem_path}/#{check_name}"

describe 'ruby environment' do
  it_behaves_like 'ruby checks', check
end

describe file(check) do
  it { should be_file }
  it { should be_executable }
end

describe command("#{check} -u http://localhost/node -m 'process.count' -c 50 -w 100 -C 300 -W 250") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(Regexp.new(Regexp.escape('CheckDcosApi OK: process.count = 208'))) }
end

describe command("#{check} -u http://localhost/node -m 'network.in' -f 'interface:dummy1' -c 50 -w 100 -C 300 -W 250") do
  its(:exit_status) { should eq 2 }
  its(:stdout) { should match(Regexp.new(Regexp.escape('CheckDcosApi CRITICAL: network.in = 0'))) }
end
