module OpsworksPassenger
  module_function
  def expand_passenger_root(root_path, passenger_vars)
    root_path % {
      :ruby_version_dir => passenger_vars[:ruby_version_dir],
      :passenger_version => passenger_vars[:version]
    }
  end
end
