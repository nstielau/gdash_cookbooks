execute "reload-systemd" do
  command "systemctl --system daemon-reload"
  action :nothing
end

template "/etc/systemd/system/http_gdash.service" do
  mode "0640"
  source "gdash.service.erb"
  variables({:description => "HTTP for wallboard",
             :options => "--port 80",
             :config_file => "/opt/gdash/http_config.ru"})
  notifies :run, "execute[reload-systemd]", :immediately
end

service "http_gdash.service" do
  action [:start, :enable]
  supports :status => true, :restart => true
  provider Chef::Provider::Service::Systemd
end
