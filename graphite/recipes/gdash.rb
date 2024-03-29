gem_package "bundle"

execute "bundle" do
  cwd "/opt/gdash"
  command "bundle install"
  action :nothing
end

git "/opt/gdash" do      
  repository "https://github.com/ripienaar/gdash.git"
  revision 'master'
  action :sync
  notifies :run, "execute[bundle]", :immediately
end

git "/opt/gdash/demo_dashboards" do      
  repository "https://github.com/nstielau/gdash_demo.git"
  revision 'master'
  action :sync
  notifies :restart, "service[gdash.service]", :delayed
end

template "/opt/gdash/config/gdash.yaml" do
  source "gdash.yaml.erb"
  notifies :restart, "service[gdash.service]", :delayed
end

execute "reload-systemd" do
  command "systemctl --system daemon-reload"
  action :nothing
end

template "/etc/systemd/system/gdash.service" do
  mode "0640"
  source "gdash.service.erb"
  variables({:description => "HTTP for wallboard",
             :options => "--port 8080",
             :config_file => "/opt/gdash/config.ru"})
  notifies :run, "execute[reload-systemd]", :immediately
  notifies :restart, "service[gdash.service]", :delayed
end

service "gdash.service" do
  action [:start, :enable]
  supports :status => true, :restart => true
  provider Chef::Provider::Service::Systemd
end

template "/etc/httpd/conf.d/gdash.conf" do
  source "gdash-vhost.conf.erb"
  notifies :restart, "service[httpd.service]", :delayed
end