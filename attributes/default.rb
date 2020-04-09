# Overrides of opsworks nginx attributes.

override[:opsworks][:deploy_user][:group] = 'nginx'
override[:nginx][:worker_processes] = node[:cpu][:total] * 3
override[:nginx][:client_max_body_size] = "100M"
override[:nginx][:gzip_http_version] = "1.1"
override[:nginx][:gzip_comp_level] = "8"
base_gzip_types = node[:nginx][:gzip_types]
override[:nginx][:gzip_types] = (base_gzip_types + %w[application/json application/javascript])

# Don't force redirect from http to https by default by keeping [:nginx][:default_location_includes] empty
default[:nginx][:default_location_includes_passenger] = nil

# SSL configuration
default[:nginx][:use_hsts] = false
default[:nginx][:ssl_dir] = "#{node[:nginx][:dir]}/ssl"
default[:nginx][:dh_key] = "#{node[:nginx][:ssl_dir]}/dhparam.pem"
default[:nginx][:dh_key_bits] = 4096

# Custom configuration variables
default[:nginx][:worker_rlimit_nofile] = nil
default[:nginx][:connection_processing_method] = "epoll"
default[:nginx][:send_timeout] = "60s"

# Custom Nginx package with passenger module
default[:nginx][:custom_package][:package_location] = "/usr/src/rpm/RPMS/x86_64/"
default[:nginx][:custom_package][:source] = nil

# Static maintenance page
default[:nginx][:prefix_dir] = "/usr/share/nginx"
default[:nginx][:serve_maintenance_page] = false
default[:nginx][:maintenance_file] = "#{node[:nginx][:prefix_dir]}/html/maintenance.html"

# Try static files for request before sending to passenger web application.
default[:nginx][:try_static_files] = false

# Mark the Nginx server blocks as the `default_server` for name-based virtual hosting.
# Note, only a single site/app is supported on a server when this is enabled due to lack of app-scoped configuration in OpsWorks with Chef 11.4.
default[:nginx][:default_server] = false

default[:nginx][:restart_on_deploy] = false
default[:nginx][:log_format] = {
    "main" => %q['$remote_addr - $remote_user [$time_local]  '
                '"$request" $status $body_bytes_sent '
                '"$http_referer" "$http_user_agent"']
}
default[:nginx][:log_format_name] = 'main'

default[:nginx][:status][:allow] = %w[127.0.0.1]

# By default, nginx is not configured to accept proxy protocol
default[:nginx][:proxy_protocol_enable] = false

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

# Passenger Monitor
default[:passenger][:monitor][:soft_memory_limit] = 250
default[:passenger][:monitor][:hard_memory_limit] = 500
default[:passenger][:monitor][:requests_processed_limit] = 5000
default[:passenger][:monitor][:app_name] = nil

# Passenger
default[:passenger][:version] = "5.0.16"
default[:passenger][:rack_version] = "1.6.4" # This is required to support ruby < 2.2 (Rack 2 requires >= 2.2)

case node[:opsworks][:ruby_version]
when /^1\.8/
    default[:passenger][:ruby_gem_dir] = '/usr/local/lib/ruby/gems/1.8'
when /^1\.9/
    default[:passenger][:ruby_gem_dir] = '/usr/local/lib/ruby/gems/1.9.1'
when /^2\.0/
    default[:passenger][:ruby_gem_dir] = '/usr/local/lib/ruby/gems/2.0.0'
when /^2\.1/
    default[:passenger][:ruby_gem_dir] = '/usr/local/lib/ruby/gems/2.1.0'
when /^2\.2/
    default[:passenger][:ruby_gem_dir] = '/usr/local/lib/ruby/gems/2.2.0'
when /^2\.3/
    default[:passenger][:ruby_gem_dir] = '/usr/local/lib/ruby/gems/2.3.0'
when /^2\.6/
    default[:passenger][:ruby_gem_dir] = '/usr/local/lib/ruby/gems/2.6.0'
else
    raise "Unsupported Ruby version '#{node[:opsworks][:ruby_version]}'. Unable to set passenger ruby_gem_dir."
end


# This value is expanded with String#format using a hash containing
# `ruby_gem_dir` and `passenger_version` as substitution variables and used
# instead of the :passenger_root value below if the value is not overridden.
# Thus, the default value for :passenger_root is dynamically determined based on
# the installed ruby.
default[:passenger][:passenger_root_template] = "%{ruby_gem_dir}/gems/passenger-%{passenger_version}"

default[:passenger][:conf][:passenger_root] = "/usr/local/lib/ruby/gems/1.9.1/gems/passenger-#{node[:passenger][:version]}"
default[:passenger][:conf][:passenger_ruby] = node[:ruby_wrapper][:install_path]

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
default[:passenger][:conf][:passenger_min_instances] = min_app_processes
default[:passenger][:conf][:passenger_max_pool_size] = max_app_processes

default[:passenger][:conf][:passenger_max_instances_per_app] = 0
default[:passenger][:conf][:passenger_spawn_method] = "smart"
default[:passenger][:conf][:passenger_pool_idle_time] = 300
default[:passenger][:conf][:passenger_max_requests] = 0
default[:passenger][:conf][:passenger_gem_binary] = nil
default[:passenger][:conf][:passenger_max_preloader_idle_time] = 0
default[:passenger][:conf][:passenger_default_user] = nil
default[:passenger][:conf][:passenger_default_group] = nil
default[:passenger][:conf][:passenger_log_level] = 0
default[:passenger][:conf][:passenger_friendly_error_pages] = nil
default[:passenger][:conf][:passenger_buffers] = '8 16k'
default[:passenger][:conf][:passenger_buffer_size] = '32k'
default[:passenger][:conf][:passenger_user_switching] = nil
default[:passenger][:conf][:passenger_default_user] = nil
default[:passenger][:conf][:passenger_default_group] = nil
