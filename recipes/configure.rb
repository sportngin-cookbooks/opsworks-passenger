template "#{node[:nginx][:dir]}/nginx.conf" do
  cookbook "nginx"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

template "#{node[:nginx][:dir]}/conf.d/passenger.conf" do
  source "passenger.conf.erb"
  owner  "root"
  group  "root"
  mode   "0644"
end

template "#{node[:nginx][:dir]}/sites-available/default" do
  source "default_site.erb"
  owner "root"
  group "root"
  mode 0644
end
if node[:nginx][:default_site][:enable]
  execute "nxensite default" do
    command "/usr/sbin/nxensite default"
    not_if do File.symlink?("#{node[:nginx][:dir]}/sites-enabled/000-default") end
  end
else
  execute "nxdissite default" do
    command "/usr/sbin/nxdissite default"
    only_if do File.symlink?("#{node[:nginx][:dir]}/sites-enabled/000-default") end
  end
end

service "nginx" do
  action :reload
end
