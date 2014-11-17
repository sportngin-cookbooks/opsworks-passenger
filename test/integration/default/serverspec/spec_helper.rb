require 'serverspec'

# Required by serverspec
set :backend, :exec

# Fix root's PATH for serverspec resources like package and service to work.
set :path, '/usr/local/sbin:/usr/sbin:/sbin:$PATH'
