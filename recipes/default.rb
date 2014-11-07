install_method = node['nginx']['install_method']
if %w(package source).include? install_method
  include_recipe "nginx::#{node['nginx']['install_method']}"
else
  include_recipe "opsworks-passenger::custom_package"
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action   :start
end

node['nginx']['default']['modules'].each do |ngx_module|
  include_recipe "nginx::#{ngx_module}"
end
