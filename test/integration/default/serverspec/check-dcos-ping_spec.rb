# frozen_string_literal: true

require 'spec_helper'

gem_path = '/usr/local/bin'
check_name = 'check-dcos-ping.rb'
check = "#{gem_path}/#{check_name}"

describe command("which #{check}") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(Regexp.new(Regexp.escape(check))) }
end
#
describe file(check) do
  it { should be_file }
  it { should be_executable }
end

describe command("#{check} -u http://localhost/ping") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(Regexp.new(Regexp.escape('CheckDcosPing OK: OK = true'))) }
end
