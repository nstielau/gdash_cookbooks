git "/opt/gdash" do      
  repository "https://github.com/ripienaar/gdash.git"
  revision 'master'
  action :sync
end

execute "reload-systemd" do
  command "systemctl --system daemon-reload"
  action :nothing
end

template "/etc/systemd/system/gdash.service" do
  mode "0640"
  source "gdash.service.erb"
  variables({:description => "HTTP for wallboard",
             :options => "--port 80",
             :config_file => "/opt/gdash/config.ru"})
  notifies :run, "execute[reload-systemd]", :immediately
end

service "gdash.service" do
  action [:start, :enable]
  supports :status => true, :restart => true
  provider Chef::Provider::Service::Systemd
end
