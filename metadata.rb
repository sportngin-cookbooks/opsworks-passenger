name             'opsworks-passenger'
maintainer       'Sport Ngin'
maintainer_email 'platform-ops@sportngin.com'
license          'MIT'
description      'Installs/Configures passenger app server with Nginx web server on Amazon OpsWorks.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'

supports 'amazon'

depends 'build-essential'

# opsworks-cookbooks
depends 'deploy'
depends 'ruby'
depends 'scm_helper'
depends 'nginx'
