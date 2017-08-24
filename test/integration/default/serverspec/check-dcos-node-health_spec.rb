# frozen_string_literal: true

require 'spec_helper'
require 'shared_spec'

gem_path = '/usr/local/bin'
check_name = 'check-dcos-node-health.rb'
check = "#{gem_path}/#{check_name}"

describe 'ruby environment' do
  it_behaves_like 'ruby checks', check
end

describe command("#{check} -u http://localhost/system/health/nodesi/fail") do
  its(:exit_status) { should eq 2 }
  its(:stdout) { should match(Regexp.new(Regexp.escape('CheckDcosNodeHealth CRITICAL: master.nodes.unhealthy = 1'))) }
end

describe command("#{check} -u http://localhost/system/health/units") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(Regexp.new(Regexp.escape('CheckDcosNodeHealth OK: nodes.unhealthy = 0'))) }
end
