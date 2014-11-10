override[:nginx][:install_method] = 'custom_package'

default[:custom_package][:package_location] = '/usr/src/rpm/RPMS/x86_64/'
default[:custom_package][:source] = 'https://s3.amazonaws.com/sportngin-packages/public/nginx-1.2.9-passenger1.amzn1.x86_64.rpm'

default[:nginx][:default_site] = true
override[:nginx][:client_max_body_size] = '100M'
