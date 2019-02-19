module OpsworksPassenger
  module_function

  def passenger_conf(node)
    node[:passenger][:conf].merge(:passenger_root => expand_passenger_root(node))
  end

  def expand_passenger_root(node)
    ruby_gem_dir = node[:passenger][:ruby_gem_dir] || `ruby -rubygems -e 'print Gem.dir'`
    node[:passenger][:conf][:passenger_root] % {
      :ruby_gem_dir => ruby_gem_dir,
      :passenger_version => node[:passenger][:version]
    }
  end
end
