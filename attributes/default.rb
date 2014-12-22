# Overrides of opsworks nginx attributes.
override[:opsworks][:deploy_user][:group] = 'nginx'
override[:nginx][:worker_processes] = node[:cpu][:total] * 3
override[:nginx][:client_max_body_size] = "100M"
override[:nginx][:gzip_http_version] = "1.1"
override[:nginx][:gzip_comp_level] = "8"

# Custom Nginx package with passenger module
default[:nginx][:custom_package][:package_location] = "/usr/src/rpm/RPMS/x86_64/"
default[:nginx][:custom_package][:source] = nil

# Static maintenance page
default[:nginx][:prefix_dir] = "/usr/share/nginx"
default[:nginx][:serve_maintenance_page] = false
default[:nginx][:maintenance_file] = "#{node[:nginx][:prefix_dir]}/html/maintenance.html"

# Try static files for request before sending to passenger web application.
default[:nginx][:try_static_files] = false

# rubywrapper
default[:ruby_wrapper][:install_path] = "/usr/local/bin/ruby-wrapper.sh"
default[:ruby_wrapper][:ruby_binary] = "/usr/local/bin/ruby"
# Size of a heap slot is 40 bytes. Start heap of app at 125 MB, which results in app memory footprint of around 330MB.
default[:ruby_wrapper][:heap_min_slots] = 3276800
# 30 million calls between garbage collection.
default[:ruby_wrapper][:gc_malloc_limit] = 30000000
# Number of heap slots that should be available after a garbage collector run.
default[:ruby_wrapper][:heap_free_min] = 100000
default[:ruby_wrapper][:extra_env_vars] = {}


# Passenger
default[:passenger][:version] = "3.0.21"
default[:passenger][:root] = "/usr/local/lib/ruby/gems/1.9.1/gems/passenger-#{node[:passenger][:version]}"
default[:passenger][:ruby] = node[:ruby_wrapper][:install_path]

# http://blog.phusion.nl/2013/03/12/tuning-phusion-passengers-concurrency-settings/
default[:passenger][:optimize_for] = 'processing'
default[:passenger][:avg_app_process_memory] = 100 # Mb
case node[:passenger][:optimize_for]
  when 'blocking_io'
    total_mem = (node[:memory][:total][0..-3].to_i / 1024) # Mb
    max_app_processes = ((total_mem * 0.75) / default[:passenger][:avg_app_process_memory]).to_i
    min_app_processes = [1, (max_app_processes / 2).to_i].max
  when 'processing'
    min_app_processes = max_app_processes = node[:cpu][:total] * 2
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


