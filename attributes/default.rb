# Local RPM package
default['rpm']['package_location'] = '/usr/src/rpm/RPMS/x86_64/'
default[:nginx_local_rpms] = {
    '1.2.9' => 'nginx-1.2.9-passenger1.amzn1.x86_64.rpm'
}

# Compile from source
override['nginx']['install_method'] = 'source'
override['nginx']['version'] = '1.2.9'
override['nginx']['source']['checksum'] = 'b8d104542c8b74161147762e31428cc3'

# so the perl module finds its symbols
override['nginx']['configure_flags'] = %W(
  --with-ld-opt="-Wl,-E"
)

override['nginx']['passenger']['version'] = '3.0.21'
# Need to manually set passenger root/ruby since install of ruby-devel package pollutes ohai's language.ruby
override['nginx']['passenger']['root'] = "/usr/local/lib/ruby/gems/1.9.1/gems/passenger-#{node['nginx']['passenger']['version']}"
override['nginx']['passenger']['ruby'] = '/usr/local/bin/ruby'

override['nginx']['gzip_static'] = 'on'
override['nginx']['client_max_body_size'] = '100M'
override['nginx']['source']['modules']  = %w(
  opsworks-passenger::nginx_http_flv_module
  nginx::http_gzip_static_module
  nginx::http_perl_module
  nginx::http_realip_module
  nginx::http_ssl_module
  nginx::http_stub_status_module
  nginx::ipv6
  nginx::passenger
)

