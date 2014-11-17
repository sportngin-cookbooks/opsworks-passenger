define :passenger_nginx_app do
  deploy = params[:deploy]
  application = params[:application]

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
    cookbook "opsworks-passenger"
    template "nginx_site.erb"
    deploy deploy
    application deploy
  end
end