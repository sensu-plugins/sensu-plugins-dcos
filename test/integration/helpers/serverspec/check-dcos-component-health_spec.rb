# frozen_string_literal: true

require 'spec_helper'
require 'shared_spec'

shared_examples 'check-dcos-component-health.rb' do
  gem_path = '/usr/local/bin'
  check_name = 'check-dcos-component-health.rb'
  check = "#{gem_path}/#{check_name}"

  describe 'ruby environment' do
    it_behaves_like 'ruby checks', check
  end

  describe command("#{check} -u http://localhost/system/health/units") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(Regexp.new(Regexp.escape('CheckDcosComponentHealth OK: components.unhealthy = 0'))) }
  end

  describe command("#{check} -u http://localhost/system/health/units/fail") do
    its(:exit_status) { should eq 2 }
    its(:stdout) { should match(Regexp.new(Regexp.escape('CheckDcosComponentHealth CRITICAL: components.unhealthy = 2'))) }
  end

  describe command("#{check} -u http://localhost/system/health/units -c 'dcos-mesos-slave-public.service'") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(Regexp.new(Regexp.escape('CheckDcosComponentHealth OK: dcos-mesos-slave-public.service = 0'))) }
  end

  describe command("#{check} -u http://localhost/system/health/units/fail -c 'dcos-mesos-slave-public.service'") do
    its(:exit_status) { should eq 2 }
    its(:stdout) { should match(Regexp.new(Regexp.escape('CheckDcosComponentHealth CRITICAL: dcos-mesos-slave-public.service = 1'))) }
  end
end
