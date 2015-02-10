# Create or update maintenance configuration variable.
service "nginx" do
  action :nothing
  supports :start => true, :stop => true, :reload => true, :restart => true
end

opsworks_passenger_nginx_server_conf "maintenance" do
  source "maintenance.conf.erb"
  if node[:nginx][:restart_on_deploy]
    notifies :reload, "service[nginx]", :delayed
  end
  variables({ :maintenance => node[:nginx][:serve_maintenance_page] })
end
