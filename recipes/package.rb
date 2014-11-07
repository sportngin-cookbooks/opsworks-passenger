directory node[:rpm][:package_location] do
  action :create
  recursive true
  owner "root"
  group "root"
end

package_file = node[:nginx_local_rpms][node[:nginx][:version]]
cookbook_file "#{node[:rpm][:package_location]}#{package_file}" do
  source package_file
  action :create
  owner "root"
  group "root"
end

rpm_package "nginx" do
  source "#{node[:rpm][:package_location]}#{package_file}"
  not_if "nginx -v | grep #{node[:nginx][:version]}"
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action   [ :enable, :start ]
end
