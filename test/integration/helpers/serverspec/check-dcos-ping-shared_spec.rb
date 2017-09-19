# frozen_string_literal: true

require 'spec_helper'
require 'shared_spec'

gem_path = '/usr/local/bin'
check_name = 'check-dcos-ping.rb'
check = "#{gem_path}/#{check_name}"

describe 'ruby environment' do
  it_behaves_like 'ruby checks', check
end

describe file(check) do
  it { should be_file }
  it { should be_executable }
end

describe command("#{check} -u http://localhost/ping") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(Regexp.new(Regexp.escape('CheckDcosPing OK: OK = true'))) }
end
