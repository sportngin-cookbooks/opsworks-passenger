# Install dependencies for building passenger nginx extensions
include_recipe "build-essential"
package "curl-devel"
package "zlib-devel"

gem_package "passenger" do
  version node[:passenger][:version]
  not_if "/usr/local/bin/gem list | grep 'passenger (#{node[:passenger][:version]}'"
end

bash "Setup Nginx integration in passenger gem" do
  code "rake nginx RELEASE=yes"
  cwd node[:passenger][:conf]["passenger_root"]
  action :nothing
  subscribes :run, 'gem_package[passenger]', :immediately
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

unless node[:nginx][:restart_on_deploy]
  log "Initial setup and deploy, notifying nginx to reload at end of run." do
    notifies :reload, "service[nginx]", :delayed
  end
end