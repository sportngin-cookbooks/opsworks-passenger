site :opscode

def opsworks_cookbook(name, branch='release-chef-11.4')
  cookbook name, github: 'aws/opsworks-cookbooks', branch: branch, rel: name
end
def unused_cookbook(name)
  dir = '.empty-cookbook'
  Dir.mkdir(dir) unless Dir.exist?(dir)
  File.open("#{dir}/metadata.rb", 'w') {} unless File.exist?("#{dir}/metadata.rb")
  cookbook name, path: dir
end

opsworks_cookbook 'ruby'
group :ruby_dependencies do
  opsworks_cookbook 'dependencies'
  opsworks_cookbook 'gem_support'
  opsworks_cookbook 'packages'
  unused_cookbook 'ruby_enterprise'
  opsworks_cookbook 'opsworks_commons'
  opsworks_cookbook 'opsworks_initial_setup'
  opsworks_cookbook 'opsworks_bundler'
  opsworks_cookbook 'opsworks_rubygems'
end

opsworks_cookbook 'deploy'
group :deploy_dependencies do
  opsworks_cookbook 'dependencies'
  opsworks_cookbook 'gem_support'
  unused_cookbook 'apache2'
  unused_cookbook 'mod_php5_apache2'
  opsworks_cookbook 'nginx'
  opsworks_cookbook 'ssh_users'
  opsworks_cookbook 'opsworks_agent_monit'
  unused_cookbook 'passenger_apache2'
  opsworks_cookbook 'rails'
  unused_cookbook 'unicorn'
  unused_cookbook 'opsworks_java'
  unused_cookbook 'php'
  unused_cookbook 'mysql'
  unused_cookbook 'opsworks_postgresql'
  opsworks_cookbook 'scm_helper'
end

opsworks_cookbook 'nginx'

metadata
