# frozen_string_literal: true

require 'spec_helper'

gem_path = '/usr/local/bin'
check_name = 'check-dcos-container-count.rb'
check = "#{gem_path}/#{check_name}"

describe command("which #{check}") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(Regexp.new(Regexp.escape(check))) }
end

describe file(check) do
  it { should be_file }
  it { should be_executable }
end

describe command("#{check} -u http://localhost/containers -C 200 -W 150") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(Regexp.new(Regexp.escape('CheckDcosContainerCount OK: container.count = 3'))) }
end
