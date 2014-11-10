include_recipe "opsworks-passenger::custom_package"

directory node[:nginx][:dir] do
  owner 'root'
  group 'root'
  mode '0755'
end

directory node[:nginx][:log_dir] do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

%w{sites-available sites-enabled conf.d}.each do |dir|
  directory File.join(node[:nginx][:dir], dir) do
    owner 'root'
    group 'root'
    mode '0755'
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

template "nginx.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  cookbook "nginx"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

template "#{node[:nginx][:dir]}/sites-available/default" do
  source "default-site.erb"
  owner "root"
  group "root"
  mode 0644
end


include_recipe "nginx::service"

service "nginx" do
  action [ :enable, :start ]
end

if node[:nginx][:default_site]
  execute "nxensite default" do
    command "/usr/sbin/nxensite default"
    notifies :reload, "service[nginx]"
    not_if do File.symlink?("#{node[:nginx][:dir]}/sites-enabled/default") end
  end
end
