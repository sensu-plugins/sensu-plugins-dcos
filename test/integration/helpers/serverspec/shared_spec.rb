# frozen_string_literal: true

require 'spec_helper'

describe command('which ruby') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/\/usr\/local\/bin\/ruby/) }
end

describe command('which gem') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/\/usr\/local\/bin\/gem/) }
end
