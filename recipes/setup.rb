package "curl-devel"

gem_package "passenger" do
  version node["passenger"]["version"]
end

include_recipe "opsworks-passenger::custom_package"

directory node[:nginx][:dir] do
  owner "root"
  group "root"
  mode "0755"
end

directory node[:nginx][:log_dir] do
  mode 0755
  owner node[:nginx][:user]
end

%w{sites-available sites-enabled conf.d}.each do |dir|
  directory File.join(node[:nginx][:dir], dir) do
    owner "root"
    group "root"
    mode "0755"
  end
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

bash "Setup Nginx integration in passenger gem" do
  code "rake nginx RELEASE=yes"
  cwd node[:passenger][:root]
end


if node[:nginx][:default_site][:enable]
  directory node[:nginx][:default_site][:path] do
    mode 0755
    owner node[:nginx][:user]
  end
  directory "#{node[:nginx][:default_site][:path]}/public" do
    mode 0755
    owner node[:nginx][:user]
  end
  directory "#{node[:nginx][:default_site][:path]}/tmp" do
    mode 0755
    owner node[:nginx][:user]
  end
  cookbook_file "#{node[:nginx][:default_site][:path]}/config.ru" do
    mode 0755
    owner node[:nginx][:user]
    source "default_site/config.ru"
  end
  cookbook_file "#{node[:nginx][:default_site][:path]}/public/static.txt" do
    mode 0755
    owner node[:nginx][:user]
    source "default_site/static.txt"
  end
end


include_recipe "nginx::service"
service "nginx" do
  action [ :enable, :start ]
end

