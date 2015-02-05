# Install dependencies for building passenger nginx extensions
include_recipe "build-essential"
package "curl-devel"
package "zlib-devel"

gem_package "passenger" do
  version node[:passenger][:version]
  not_if "gem list | egrep 'passenger (#{node[:passenger][:version]}'"
end

bash "Setup Nginx integration in passenger gem" do
  code "rake nginx RELEASE=yes"
  cwd node[:passenger][:conf]["passenger_root"]
  not_if { ::File.directory? "#{node[:passenger][:conf]["passenger_root"]}/agents" }
end

include_recipe "opsworks-passenger::custom_package"

directory node[:nginx][:dir] do
  owner "root"
  group "root"
  mode "0755"
end

%w{sites-available sites-enabled conf.d shared_server.conf.d http_server.conf.d ssl_server.conf.d}.each do |dir|
  directory File.join(node[:nginx][:dir], dir) do
    owner "root"
    group "root"
    mode "0755"
  end
end

directory node[:nginx][:log_dir] do
  mode 0755
  owner node[:nginx][:user]
end

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    cookbook "nginx"
    source "#{nxscript}.erb"
    mode 0755
    owner "root"
    group "root"
  end
end


template "#{node[:nginx][:dir]}/nginx.conf" do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

opsworks_passenger_nginx_server_conf "security" do
  source "security.conf.erb"
end

cookbook_file "#{node[:nginx][:prefix_dir]}/html/maintenance.html" do
  source "maintenance.html"
  group "root"
  owner "root"
  mode 0644
end
include_recipe "opsworks-passenger::maintenance"


template node[:ruby_wrapper][:install_path] do
  source "ruby-wrapper.sh.erb"
  owner "root"
  group "root"
  mode 0755
  action :create
  variables(
      :ruby_binary => node[:ruby_wrapper][:ruby_binary],
      :heap_min_slots => node[:ruby_wrapper][:heap_min_slots],
      :gc_malloc_limit => node[:ruby_wrapper][:gc_malloc_limit],
      :heap_free_min => node[:ruby_wrapper][:heap_free_min],
      :extra_env_vars => node[:ruby_wrapper][:extra_env_vars]
  )
end

opsworks_passenger_nginx_conf "passenger" do
  source "passenger.conf.erb"
  variables(
      :root => node[:passenger][:root],
      :ruby => node[:passenger][:ruby],
      :config => node[:passenger]
  )
end

include_recipe "nginx::service"
service "nginx" do
  action [ :enable, :start ]
end
