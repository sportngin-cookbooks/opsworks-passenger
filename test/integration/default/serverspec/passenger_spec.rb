require 'spec_helper'

describe port(80) do
  it { should be_listening }
end

describe command('curl -I localhost') do
  its(:stdout) { should match "200 OK" }
end

describe command('curl localhost') do
  its(:stdout) { should match "Test Rack App" }
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

describe file('/etc/nginx/conf.d/passenger.conf') do
  it { should be_file }
  its(:content) { should match <<CONF
# https://github.com/phusion/passenger/tree/stable-3.0/doc

passenger_root /usr/local/lib/ruby/gems/1.9.1/gems/passenger-3.0.21;
passenger_ruby /usr/local/bin/ruby-wrapper.sh;
passenger_min_instances 4;
passenger_max_pool_size 4;
passenger_max_instances_per_app 0;
passenger_spawn_method smart-lv2;
passenger_pool_idle_time 300;
passenger_max_requests 0;

rails_framework_spawner_idle_time 0;
rails_app_spawner_idle_time 0;


passenger_log_level 0;

passenger_buffers 8 16k;
passenger_buffer_size 32k;
passenger_use_global_queue on;
CONF
  }
end
