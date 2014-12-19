# Create or update maintenance configuration variable.
service "nginx" do
  action :nothing
  supports :start => true, :stop => true, :reload => true, :restart => true
end
template "#{node[:nginx][:dir]}/shared_server.conf.d/maintenance.conf" do
  source "maintenance.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :reload, "service[nginx]", :delayed
  variables({ :maintenance => node[:nginx][:serve_maintenance_page] })
end