require 'spec_helper'

describe package('nginx') do
  it { should be_installed.with_version('1.2.9') }
end

describe service('nginx') do
  it { should be_enabled }
  it { should be_running }
  # it { should be_monitored_by('monit') }
end

describe command('nginx -V') do
  its(:stdout) { should match 'passenger'}
end
