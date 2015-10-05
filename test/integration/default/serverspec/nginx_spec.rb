require 'spec_helper'

describe package('nginx') do
  it { should be_installed.with_version('1.8.0') }
end

describe service('nginx') do
  it { should be_enabled }
  it { should be_running }
end

describe command('passenger-status') do
  its(:stdout) { should match 'Phusion_Passenger'}
  its(:stdout) { should match 'nginx/1.8.0'}
end

describe file('/etc/nginx/nginx.conf') do
  it { should be_file }
  its(:content) { should include 'use epoll' }
  its(:content) { should include 'worker_rlimit_nofile 4096' }
  its(:content) { should include 'gzip_types application/x-javascript application/xhtml+xml application/xml application/xml+rss text/css text/javascript text/plain text/xml application/json;' }
end

describe file('/etc/nginx/shared_server.conf.d/maintenance.conf') do
  it { should be_file }
  its(:content) { should match /set \$maintenance 0;/}
end

describe command('curl -i localhost/system/maintenance.html') do
  its(:stdout) { should_not match '503 Service Temporarily Unavailable' }
  its(:stdout) { should_not match '<div id="maintenance">' }
end

describe command('curl localhost/tacos.txt') do
  its(:stdout) { should_not match "yum" }
end

describe file('/etc/nginx/sites-enabled/test_app') do
  its(:content) { should match <<CONF
server {
  listen   80;
  server_name  test-kitchen.sportngin.com #{`hostname | tr -d '\n'`};
  access_log  /var/log/nginx/test-kitchen.sportngin.com.access.log main;

  root   /srv/test-www/test_rack_app/current/public/;

  location / {
    if ($maintenance) {
      return 503;
      break;
    }
    # Turn on the passenger Nginx helper for this location.
    passenger_enabled on;

    # These don't seem to work in stack, which is in the http {} block
    passenger_set_header HTTP_X_FORWARDED_FOR   $proxy_add_x_forwarded_for;
    passenger_set_header HTTP_X_REAL_IP         $remote_addr;
    passenger_set_header HTTP_HOST              $http_host;
    passenger_set_header HTTP_X_FORWARDED_PROTO $scheme;
    # https://docs.newrelic.com/docs/apm/other-features/request-queueing/request-queue-server-configuration-examples#nginx
    passenger_set_header HTTP_X_REQUEST_START "t=${msec}";

    # Rails 3.0 apps that use rack-ssl use SERVER_PORT to generate a https
    # URL. Since internally nginx runs on a different port, the generated
    # URL looked like this: https://host:81/ instead of https://host/
    # By setting SERVER_PORT this is avoided.
    passenger_set_header SERVER_PORT            80;

    #
    # Define the rack/rails application environment.
    #
    rack_env test;
  }


  error_page 503 /maintenance.html;
  location = /maintenance.html {
    root /usr/share/nginx/html;
  }

  location /nginx_status {
    stub_status on;
    access_log off;
    allow 127.0.0.1;
    deny all;
  }

  include /etc/nginx/shared_server.conf.d/*.conf;
  include /etc/nginx/http_server.conf.d/*.conf;
}

server {
  listen   443;
  server_name  test-kitchen.sportngin.com #{`hostname | tr -d '\n'`};
  access_log  /var/log/nginx/test-kitchen.sportngin.com-ssl.access.log main;

  ssl on;
  ssl_certificate /etc/nginx/ssl/test-kitchen.sportngin.com.crt;
  ssl_certificate_key /etc/nginx/ssl/test-kitchen.sportngin.com.key;


  root   /srv/test-www/test_rack_app/current/public/;


  location / {
    if ($maintenance) {
      return 503;
      break;
    }
    # Turn on the passenger Nginx helper for this location.
    passenger_enabled on;

    # These don't seem to work in stack, which is in the http {} block
    passenger_set_header HTTP_X_FORWARDED_FOR   $proxy_add_x_forwarded_for;
    passenger_set_header HTTP_X_REAL_IP         $remote_addr;
    passenger_set_header HTTP_HOST              $http_host;
    passenger_set_header HTTP_X_FORWARDED_PROTO $scheme;
    # https://docs.newrelic.com/docs/apm/other-features/request-queueing/request-queue-server-configuration-examples#nginx
    passenger_set_header HTTP_X_REQUEST_START "t=${msec}";

    # Rails 3.0 apps that use rack-ssl use SERVER_PORT to generate a https
    # URL. Since internally nginx runs on a different port, the generated
    # URL looked like this: https://host:81/ instead of https://host/
    # By setting SERVER_PORT this is avoided.
    passenger_set_header SERVER_PORT            443;

    #
    # Define the rack/rails application environment.
    #
    rack_env test;
  }

  error_page 503 /maintenance.html;
  location = /maintenance.html {
    root /usr/share/nginx/html;
  }

  include /etc/nginx/shared_server.conf.d/*.conf;
  include /etc/nginx/ssl_server.conf.d/*.conf;
}
CONF
  }
end
