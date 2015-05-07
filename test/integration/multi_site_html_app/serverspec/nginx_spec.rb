require 'serverspec'

# Required by serverspec
set :backend, :exec

# Fix root's PATH for serverspec resources like package and service to work and because /usr/local/bin is missing??
set :path, '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH'
ENV['PATH']="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:#{ENV['PATH']}"

describe package('nginx') do
  it { should be_installed.with_version('1.8.0') }
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

describe file('/etc/nginx/sites-enabled/test_app') do
  its(:content) { should match <<CONF
server {
  listen   80 default_server;
  server_name  test-kitchen.sportngin.com #{`hostname | tr -d '\n'`};
  access_log  /var/log/nginx/test-kitchen.sportngin.com.access.log;

  root   /srv/test-www/test_rack_app/current/public/;

  location / {
    if ($maintenance) {
      return 503;
      break;
    }
    try_files  $uri $uri/index.html $uri.html @app_test_app;
  }
  location @app_test_app {
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
  listen   443 default_server;
  server_name  test-kitchen.sportngin.com #{`hostname | tr -d '\n'`};
  access_log  /var/log/nginx/test-kitchen.sportngin.com-ssl.access.log;

  ssl on;
  ssl_certificate /etc/nginx/ssl/test-kitchen.sportngin.com.crt;
  ssl_certificate_key /etc/nginx/ssl/test-kitchen.sportngin.com.key;


  root   /srv/test-www/test_rack_app/current/public/;


  location / {
    if ($maintenance) {
      return 503;
      break;
    }
    try_files  $uri $uri/index.html $uri.html @app_test_app_ssl;
  }
  location @app_test_app_ssl {
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
