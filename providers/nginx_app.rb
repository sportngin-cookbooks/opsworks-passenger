# nginx_app provider manages the Nginx site for a app

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  deploy = new_resource.deploy
  Chef::Log.info "Creating Nginx site for Passenger application #{deploy[:application]}"

  service "nginx" do
    supports :status => true, :restart => true, :reload => true
    action :nothing
  end
  nginx_web_app deploy[:application] do
    docroot deploy[:absolute_document_root]
    server_name deploy[:domains].first
    server_aliases deploy[:domains][1, deploy[:domains].size] unless deploy[:domains][1, deploy[:domains].size].empty?
    rails_env deploy[:rails_env]
    mounted_at deploy[:mounted_at]
    ssl_certificate_ca deploy[:ssl_certificate_ca]
    http_port deploy[:http_port] || 80
    ssl_port deploy[:ssl_port] || 443
    ssl_support deploy[:ssl_support] || false
    try_static_files node[:nginx][:try_static_files]
    cookbook "opsworks-passenger"
    template "nginx_site.conf.erb"
    deploy deploy
    application deploy
  end

  new_resource.updated_by_last_action(true)
end
