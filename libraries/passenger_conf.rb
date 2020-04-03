module OpsworksPassenger
  module_function

  def passenger_conf(node)
    node[:passenger][:conf].merge(:passenger_root => expand_passenger_root(node))
  end

  def expand_passenger_root(node)
    if node[:passenger][:conf][:passenger_root] != node.default[:passenger][:conf][:passenger_root]
      return node[:passenger][:conf][:passenger_root]
    end

    cmd = Mixlib::ShellOut.new("env -i /usr/local/bin/gem env gemdir")

    ruby_gem_dir = node[:passenger][:ruby_gem_dir] || cmd.run_command.stdout
    node[:passenger][:passenger_root_template] % {
      :ruby_gem_dir => ruby_gem_dir,
      :passenger_version => node[:passenger][:version]
    }
  end
end
