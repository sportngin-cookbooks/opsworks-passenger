# nginx_conf provider manages Nginx confs included in the http context.

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  Chef::Log.info "Creating Nginx http conf for #{new_resource.name}."
  t = template "#{node[:nginx][:dir]}/conf.d/#{new_resource.name}.conf" do
    cookbook new_resource.cookbook_name.to_s
    source new_resource.source
    mode '0644'
    variables(new_resource.variables)
    action :create
  end
  new_resource.updated_by_last_action(t.updated_by_last_action?)
end