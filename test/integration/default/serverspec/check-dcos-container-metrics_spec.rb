# frozen_string_literal: true

require 'spec_helper'
require 'shared_spec'

gem_path = '/usr/local/bin'
check_name = 'check-dcos-container-metrics.rb'
check = "#{gem_path}/#{check_name}"

describe 'ruby environment' do
  it_behaves_like 'ruby checks', check
end

describe file(check) do
  it { should be_file }
  it { should be_executable }
end

describe command("#{check} -u http://localhost/containers -m 'cpus.throttled.time' -d -M max -W 10 -C 20") do
  its(:exit_status) { should eq 1 }
  regex = Regexp.escape('CheckDcosContainersApi WARNING: max cpus.throttled.time = 10 on A4CB4E86-7730-4071-BF7F-D3AE9010140D')
  its(:stdout) { should match(Regexp.new(regex)) }
end
