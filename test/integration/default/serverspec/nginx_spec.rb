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

describe port(80) do
  it { should be_listening }
end

describe command('curl -I localhost') do
  its(:stdout) { should match "200 OK" }
end

describe command('curl localhost') do
  its(:stdout) { should match "Default Rack Site" }
end

describe command('curl localhost/static.txt') do
  its(:stdout) { should match "Static" }
end

describe command('passenger-status') do
  cpus = `grep -c ^processor /proc/cpuinfo`
  its(:stdout) { should match /max\s*=\s#{cpus.to_i * 2}/ }
  its(:stdout) { should match /count\s*=\s#{cpus.to_i * 2}/ }
end

describe command('passenger-memory-stats') do
  its(:exit_status) { should eq 0 }
end