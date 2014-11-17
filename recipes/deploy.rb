node[:deploy].each do |application, deploy|

  opsworks_deploy_user do
    deploy_data deploy
  end

  passenger_nginx_app do
    application application
    deploy deploy
  end

end
