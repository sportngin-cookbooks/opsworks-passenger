node[:deploy].each do |application, deploy|

  opsworks_deploy_user do
    deploy_data deploy
  end

  opsworks_passenger_nginx_app application do
    deploy deploy
  end

end
