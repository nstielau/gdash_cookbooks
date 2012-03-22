cron "chef_solo" do
  minute "*/15"
  command "chef-solo -j ~/solo.json"
end