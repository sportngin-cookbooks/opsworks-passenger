define :nginx_config, :name => nil, :cookbook => "opsworks-passenger", variables => nil do
  name = params[:name]
  template "/etc/nginx/conf.d/#{name}.conf" do
    source "#{name}.conf.erb"
    owner "root"
    group "root"
    mode 0644
    backup false
    action :create
    cookbook params[:cookbook]
    variables(params[:variables])
  end
end