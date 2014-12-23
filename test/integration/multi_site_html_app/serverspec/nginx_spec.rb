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

describe file('/etc/nginx/sites-enabled/test_app') do
  it { should be_file }
  its(:content) { should include ' default_server;' }
  its(:content) { should include 'try_files  $uri $uri/index.html $uri.html @app_test_app;'}
end

describe command('echo "127.0.0.1 tacos.org" | sudo tee -a /etc/hosts') do
  its(:exit_status) { should eq 0 }
  describe command('curl tacos.org/tacos/') do
    its(:stdout) { should match 'tacos' }
  end
end

