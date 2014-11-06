site :opscode

def opsworks_cookbook(name, branch='release-chef-11.4')
  cookbook name, github: 'aws/opsworks-cookbooks', branch: branch, rel: name
end

opsworks_cookbook 'ruby'
# ruby opsworks dependencies
opsworks_cookbook 'dependencies'
opsworks_cookbook 'packages'
opsworks_cookbook 'ruby_enterprise'
opsworks_cookbook 'opsworks_commons'
opsworks_cookbook 'opsworks_initial_setup'
opsworks_cookbook 'opsworks_bundler'
opsworks_cookbook 'opsworks_rubygems'

# Gem support for installing passenger for installing into system ruby (not chef ruby).
opsworks_cookbook 'gem_support'

metadata
