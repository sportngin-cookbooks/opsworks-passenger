# Overrides of opsworks nginx attributes.
override[:nginx][:install_method] = "custom_package"
override[:nginx][:worker_processes] = node[:cpu][:total] * 3
override[:nginx][:client_max_body_size] = "100M"
override[:nginx][:gzip_http_version] = "1.1"
override[:nginx][:gzip_comp_level] = "8"

# Extensions
default[:custom_package][:package_location] = "/usr/src/rpm/RPMS/x86_64/"
default[:custom_package][:source] = "https://s3.amazonaws.com/sportngin-packages/public/nginx-1.2.9-passenger1.amzn1.x86_64.rpm"

data_dir = "#{`rpm --eval '%{_datadir}' | tr -d '\n'`}/nginx"
default[:nginx][:default_site][:enable] = true
default[:nginx][:default_site][:path] = "#{data_dir}/rack"


# Passenger
default[:passenger][:version] = "3.0.21"
default[:passenger][:root] = "/usr/local/lib/ruby/gems/1.9.1/gems/passenger-#{node[:passenger][:version]}"
default[:passenger][:ruby] = node[:languages][:ruby][:ruby_bin]

# http://blog.phusion.nl/2013/03/12/tuning-phusion-passengers-concurrency-settings/
default[:passenger][:optimize_for] = 'blocking_io'
default[:passenger][:avg_app_process_memory] = 100 # Mb
case node[:passenger][:optimize_for]
  when 'blocking_io'
    total_mem = (node['memory']['total'][0..-3].to_i / 1024) # Mb
    max_app_processes = ((total_mem * 0.75) / default[:passenger][:avg_app_process_memory]).to_i
    min_app_processes = [1, (max_app_processes / 2).to_i].max
  when 'processing'
    min_app_processes = max_app_processes = node[:cpu][:total]
  else
    raise "Unsupported passenger.optimization_for value: #{node[:passenger][:optimize_for]}"
end
default[:passenger][:min_instances] = min_app_processes
default[:passenger][:max_pool_size] = max_app_processes

default[:passenger][:max_instances_per_app] = 0
default[:passenger][:spawn_method] = "smart-lv2"
default[:passenger][:pool_idle_time] = 300
default[:passenger][:max_requests] = 0
default[:passenger][:gem_binary] = nil
default[:passenger][:spawner_idle_time] = 0
default[:passenger][:default_user] = nil
default[:passenger][:default_group] = nil
default[:passenger][:log_level] = 0
default[:passenger][:friendly_error_pages] = nil
