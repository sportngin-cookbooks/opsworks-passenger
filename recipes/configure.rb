template "#{node[:nginx][:dir]}/nginx.conf" do
  cookbook "nginx"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

template "#{node[:nginx][:dir]}/shared_server.conf.d/shared.conf" do
  source "nginx_shared.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

template node[:ruby_wrapper][:install_path] do
  source "ruby-wrapper.sh.erb"
  owner "root"
  group "root"
  mode 0755
  action :create
  variables(
      :ruby_binary => node[:ruby_wrapper][:ruby_binary],
      :heap_min_slots => node[:ruby_wrapper][:heap_min_slots],
      :gc_malloc_limit => node[:ruby_wrapper][:gc_malloc_limit],
      :heap_free_min => node[:ruby_wrapper][:heap_free_min],
      :extra_env_vars => node[:ruby_wrapper][:extra_env_vars]
  )
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
  variables(
      :root_dir => node[:nginx][:default_site][:root_dir]
  )
end
if node[:nginx][:default_site][:enable]
  execute "nxensite default" do
    command "/usr/sbin/nxensite default"
    not_if do
      File.symlink?("#{node[:nginx][:dir]}/sites-enabled/default") ||
      File.symlink?("#{node[:nginx][:dir]}/sites-enabled/000-default")
    end
  end
else
  execute "nxdissite default" do
    command "/usr/sbin/nxdissite default"
    only_if do
      File.symlink?("#{node[:nginx][:dir]}/sites-enabled/default") ||
      File.symlink?("#{node[:nginx][:dir]}/sites-enabled/000-default")
    end
  end
end

service "nginx" do
  action :reload
end
