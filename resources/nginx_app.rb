actions :create
default_action :create

attribute :deploy, :kind_of => Hash, :required => true
attribute :site_template, :kind_of => String, :default => "nginx_site.conf.erb"
attribute :site_template_cookbook, :kind_of => String, :default => "opsworks-passenger"
attribute :enable, :kind_of => [TrueClass, FalseClass], :default => true