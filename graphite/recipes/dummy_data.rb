template "/usr/local/graphite_dummy_data.rb" do
  mode "0755"
  source "graphite_dummy_data.rb.erb"
end

cron "graphite_dummy_data" do
  minute "*"
  command "/usr/local/graphite_dummy_data.rb"
end