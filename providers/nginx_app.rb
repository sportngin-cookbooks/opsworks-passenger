# nginx_app provider manages the Nginx site for an app

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  deploy = new_resource.deploy
  application_name = deploy[:application]
  restart = node[:nginx][:restart_on_deploy]
  Chef::Log.info "Creating Nginx site for Passenger application #{deploy[:application]}"

  service "nginx" do
    supports :status => true, :restart => true, :reload => true
    action :nothing
  end

  template "#{node[:nginx][:dir]}/sites-available/#{application_name}" do
    Chef::Log.debug("Generating Nginx site template for #{application_name.inspect}")
    source new_resource.site_template
    owner "root"
    group "root"
    mode 0644
    cookbook new_resource.site_template_cookbook
    variables(
        :deploy => deploy,
        :application_name => application_name,
        :docroot => deploy[:absolute_document_root],
        :server_name => deploy[:domains].first,
        :server_aliases => (deploy[:domains][1, deploy[:domains].size] unless deploy[:domains][1, deploy[:domains].size].empty?),
        :rails_env => deploy[:rails_env],
        :mounted_at => deploy[:mounted_at],
        :ssl_certificate_ca => deploy[:ssl_certificate_ca],
        :http_port => deploy[:http_port] || 80,
        :ssl_port => deploy[:ssl_port] || 443,
        :ssl_support => deploy[:ssl_support] || false,
        :try_static_files => node[:nginx][:try_static_files],
        :default_server => node[:nginx][:default_server],
        :status => node[:nginx][:status],
        :dh_key => node[:nginx][:dh_key]
    )
    if restart && ::File.exists?("#{node[:nginx][:dir]}/sites-enabled/#{application_name}")
      notifies :reload, "service[nginx]", :delayed
    end
  end

  directory "#{node[:nginx][:ssl_dir]}" do
    action :create
    owner "root"
    group "root"
    mode 0700
  end

  execute 'Generate Diffie-Hellman key' do
    command "openssl dhparam -dsaparam -out #{node[:nginx][:dh_key]} #{node[:nginx][:dh_key_bits]}"
    creates node[:nginx][:dh_key]
  end

  file node[:nginx][:dh_key] do
    owner "root"
    group "root"
    mode 0600
  end

  template "#{node[:nginx][:ssl_dir]}/#{deploy[:domains].first}.crt" do
    cookbook 'nginx'
    mode '0600'
    source "ssl.key.erb"
    variables :key => deploy[:ssl_certificate]
    if restart
      notifies :restart, "service[nginx]"
    end
    only_if do
      deploy[:ssl_support]
    end
  end

  template "#{node[:nginx][:ssl_dir]}/#{deploy[:domains].first}.key" do
    cookbook 'nginx'
    mode '0600'
    source "ssl.key.erb"
    variables :key => deploy[:ssl_certificate_key]
    if restart
      notifies :restart, "service[nginx]"
    end
    only_if do
      deploy[:ssl_support]
    end
  end

  template "#{node[:nginx][:ssl_dir]}/#{deploy[:domains].first}.ca" do
    cookbook 'nginx'
    mode '0600'
    source "ssl.key.erb"
    variables :key => deploy[:ssl_certificate_ca]
    if restart
      notifies :restart, "service[nginx]"
    end
    only_if do
      deploy[:ssl_support] && deploy[:ssl_certificate_ca]
    end
  end

  file "#{node[:nginx][:dir]}/sites-enabled/default" do
    action :delete
    only_if do
      ::File.exists?("#{node[:nginx][:dir]}/sites-enabled/default")
    end
  end

  if new_resource.enable
    execute "nxensite #{application_name}" do
      command "/usr/sbin/nxensite #{application_name}"
      if restart
        notifies :reload, "service[nginx]"
      end
      not_if do ::File.symlink?("#{node[:nginx][:dir]}/sites-enabled/#{application_name}") end
    end
  else
    execute "nxdissite #{application_name}" do
      command "/usr/sbin/nxdissite #{application_name}"
      if restart
        notifies :reload, "service[nginx]"
      end
      only_if do ::File.symlink?("#{node[:nginx][:dir]}/sites-enabled/#{application_name}") end
    end
  end

  new_resource.updated_by_last_action(true)
end
