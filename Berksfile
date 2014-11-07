site :opscode

def opsworks_cookbook(name, branch='release-chef-11.4')
  cookbook name, github: 'aws/opsworks-cookbooks', branch: branch, rel: name
end

opsworks_cookbook 'ruby'
group :ruby_dependencies do
  opsworks_cookbook 'dependencies'
  opsworks_cookbook 'packages'
  opsworks_cookbook 'ruby_enterprise'
  opsworks_cookbook 'opsworks_commons'
  opsworks_cookbook 'opsworks_initial_setup'
  opsworks_cookbook 'opsworks_bundler'
  opsworks_cookbook 'opsworks_rubygems'
end

opsworks_cookbook 'deploy'
group :deploy_dependencies do
  opsworks_cookbook 'dependencies'
  opsworks_cookbook 'apache2'
  opsworks_cookbook 'mod_php5_apache2'
  # Intentional exclusion of opsworks nginx to use supermarket nginx cookbook.
  # opsworks_cookbook 'nginx'
  opsworks_cookbook 'ssh_users'
  opsworks_cookbook 'opsworks_agent_monit'
  opsworks_cookbook 'passenger_apache2'
  opsworks_cookbook 'rails'
  opsworks_cookbook 'unicorn'
  opsworks_cookbook 'opsworks_java'
  opsworks_cookbook 'php'
  opsworks_cookbook 'mysql'
  opsworks_cookbook 'opsworks_postgresql'
end

# Gem support for installing passenger for installing into system ruby (not chef ruby).
opsworks_cookbook 'gem_support'

metadata
