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

default[:passenger][:version] = "3.0.21"
default[:passenger][:root] = "#{node[:languages][:ruby][:gems_dir]}/gems/passenger-#{node[:passenger][:version]}"
default[:passenger][:ruby] = node[:languages][:ruby][:ruby_bin]
default[:passenger][:spawn_method] = "smart-lv2"
default[:passenger][:buffer_response] = "on"
default[:passenger][:max_pool_size] = 6
default[:passenger][:min_instances] = 1
default[:passenger][:max_instances_per_app] = 0
default[:passenger][:pool_idle_time] = 300
default[:passenger][:max_requests] = 0
default[:passenger][:gem_binary] = nil
default[:passenger][:spawner_idle_time] = 0
default[:passenger][:use_global_queue] = "on"
default[:passenger][:default_user] = nil
default[:passenger][:default_group] = nil
default[:passenger][:log_level] = 0
default[:passenger][:friendly_error_pages] = nil
