# Setup for test kitchen
remote_directory "/srv/test-www/test_rack_app/current" do
  files_owner node[:nginx][:user]
  files_mode 0755
  owner node[:nginx][:user]
  mode 0755
  source "test_rack_app"
end
