directory node[:custom_package][:package_location] do
  action :create
  recursive true
  owner "root"
  group "root"
end

package_file = node[:custom_package][:source].split('/').last
remote_file "#{node[:custom_package][:package_location]}#{package_file}" do
  source node[:custom_package][:source]
  action :create
  owner "root"
  group "root"
end

rpm_package "nginx" do
  source "#{node[:custom_package][:package_location]}#{package_file}"
  not_if "nginx -v | grep #{node[:nginx][:version]}"
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action   :enable
end

include_recipe 'nginx::commons'
