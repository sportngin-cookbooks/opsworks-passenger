# opsworks-passenger cookbook

[![Build Status](https://travis-ci.org/sportngin-cookbooks/opsworks-passenger.svg?branch=master)](https://travis-ci.org/sportngin-cookbooks/opsworks-passenger)

This cookbook installs and configures Nginx web server with Passenger application server.
It is a customized implementation of the AWS OpsWorks [Nginx](https://github.com/aws/opsworks-cookbooks/tree/release-chef-11.4/nginx) cookbook.

# Requirements

You need to provide a nginx package that has passenger (and any other desired modules) compiled in.

This is developed and tested against Amazon linux and intended for use within OpsWorks.

# Usage

Include this cookbook as a dependency, set package source and add recipes to run list.

# Attributes

- `node[:nginx][:custom_package][:source]` - URL to fetch Nginx package from compiled with passenger and any other custom modules.
- `node[:passenger][:optimize_for]` - Set to 'processing' or 'blocking_io' to optimize min and max processes accordingly.
# Recipes

- `setup` - Install and configure nginx and passenger. This should be run in OpsWorks setup event.
- `deploy` - Add new passenger enabled nginx site. This should be run in OpsWorks deploy event.

# Author

Author:: Sport Ngin Platform Operations (<platform-ops@sportngin.com>)
