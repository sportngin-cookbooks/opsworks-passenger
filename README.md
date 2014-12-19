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

Attributes of note:
- `node[:nginx][:custom_package][:source]` - URL to fetch Nginx package from compiled with passenger and any other custom modules.
- `node[:passenger][:optimize_for]` - Set to 'processing' or 'blocking_io' to optimize min and max processes accordingly. Defaults to `processing`.
- `node[:nginx][:try_static_files]` - Have nginx serve static files for request before deferring to Passenger application. Defaults to `false`.

See attributes source for full list of configuration options.

# Recipes

- `setup` - Install and configure nginx and passenger. This should be run in OpsWorks setup event.
- `deploy` - Add new passenger enabled nginx site. This should be run in OpsWorks deploy event.
- `maintenance` - Toggle serving of temporary static maintenance page with `node[:nginx][:serve_maintenance_page]`.

# Author

Author:: Sport Ngin Platform Operations (<platform-ops@sportngin.com>)
