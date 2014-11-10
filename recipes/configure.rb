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

if node[:nginx][:default_site]
  execute "nxensite default" do
    command "/usr/sbin/nxensite default"
    notifies :reload, "service[nginx]"
    not_if do File.symlink?("#{node[:nginx][:dir]}/sites-enabled/default") end
  end
else
  execute "nxdissite default" do
    command "/usr/sbin/nxdissite default"
    notifies :reload, "service[nginx]"
    only_if do File.symlink?("#{node[:nginx][:dir]}/sites-enabled/default") end
  end
end