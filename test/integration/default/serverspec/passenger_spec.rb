require 'spec_helper'

describe port(81) do
  it { should be_listening }
end

describe command('curl -I localhost:81') do
  its(:stdout) { should match "200 OK" }
end

describe command('curl localhost:81') do
  its(:stdout) { should match "Test Rack App" }
end

describe command('curl localhost:81/static.txt') do
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
