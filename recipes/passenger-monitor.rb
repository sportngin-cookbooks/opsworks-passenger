cookbook_file "/usr/local/bin/passenger_monitor" do
  source "passenger_monitor"
  owner "root"
  group "root"
  mode 0755
  action :create
end

package "hatools"
template "/usr/local/bin/#{node[:passenger][:monitor][:app_name]}_passenger_monitor" do
  source "passenger_monitor.sh.erb"
  owner "root"
  group "root"
  mode 0755
  action :create
  variables({
    :soft_memory_limit => node[:passenger][:monitor][:soft_memory_limit],
    :hard_memory_limit => node[:passenger][:monitor][:hard_memory_limit],
    :processed_limit => node[:passenger][:monitor][:requests_processed_limit],
    :app_name => node[:passenger][:monitor][:app_name]
  })
end

# * * * * * /usr/local/bin/<app_name>_passenger_monitor;
cron "passenger_monitor_#{node[:passenger][:monitor][:app_name]}" do
  action :create
  command "/usr/local/bin/#{node[:passenger][:monitor][:app_name]}_passenger_monitor"
end
