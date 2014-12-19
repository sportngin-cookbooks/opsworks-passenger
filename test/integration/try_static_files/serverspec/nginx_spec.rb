require 'serverspec'

# Required by serverspec
set :backend, :exec

# Fix root's PATH for serverspec resources like package and service to work and because /usr/local/bin is missing??
set :path, '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH'
ENV['PATH']="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:#{ENV['PATH']}"

describe package('nginx') do
  it { should be_installed.with_version('1.2.9') }
end

describe service('nginx') do
  it { should be_enabled }
  it { should be_running }
end

describe command('nginx -V') do
  its(:stdout) { should match 'passenger'}
end

describe command('curl localhost/tacos/') do
  its(:stdout) { should match 'tacos' }
end