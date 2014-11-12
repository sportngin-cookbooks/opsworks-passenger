require 'spec_helper'

describe command('/usr/local/bin/ruby-wrapper.sh -v') do
  its(:stdout) { should match `ruby -v` }
  its(:exit_status) { should eq 0 }
end