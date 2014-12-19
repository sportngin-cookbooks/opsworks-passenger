require 'spec_helper'

describe port(80) do
  it { should be_listening }
end

describe file('/etc/nginx/shared_server.conf.d/maintenance.conf') do
  it { should be_file }
  its(:content) { should match /set \$maintenance 1;/}
end

describe command('curl -i localhost/system/maintenance.html') do
  its(:stdout) { should match /503 Service Temporarily Unavailable/ }
  its(:stdout) { should match /<div id="maintenance">/ }
end