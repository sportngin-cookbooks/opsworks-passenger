cookbook_file "/usr/local/bin/passenger_monitor" do
  source "passenger_monitor"
  owner "root"
  group "root"
  mode 0755
  action :create
end

package "hatools"
template "/usr/local/bin/tst_passenger_monitor" do
  source "tst_passenger_monitor.sh.erb"
  owner "root"
  group "root"
  mode 0755
  action :create
  variables({
    :soft_memory_limit => node[:passenger][:monitor][:passenger_soft_memory_limit], 
    :hard_memory_limit => node[:passenger][:monitor][:passenger_hard_memory_limit],  
    :processed_limit => node[:passenger][:monitor][:passenger_requests_processed_limit]
  })
end

# * * * * * /usr/local/bin/tst_passenger_monitor;
cron "tst_passenger_monitor_ngin" do
  action :create
  command "/usr/local/bin/tst_passenger_monitor"
end
