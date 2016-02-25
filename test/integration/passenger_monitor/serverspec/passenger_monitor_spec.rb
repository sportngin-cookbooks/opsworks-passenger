require 'spec_helper'

describe command('for i in `seq 1 21`; do curl localhost; done && sleep 120') do
  its(:exit_status) { should eq 0 }
end

describe file('/var/log/messages') do
  its(:content) { should include 'passenger_monitor: Killing PID'}
  its(:content) { should include 'exceeds 20'}
end