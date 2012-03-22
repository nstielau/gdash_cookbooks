package "python-twisted"

remote_file "/usr/src/carbon-#{node.graphite.carbon.version}.tar.gz" do
  source node.graphite.carbon.uri
  checksum node.graphite.carbon.checksum
end

execute "untar carbon" do
  command "tar xzf carbon-#{node.graphite.carbon.version}.tar.gz"
  creates "/usr/src/carbon-#{node.graphite.carbon.version}"
  cwd "/usr/src"
end

execute "install carbon" do
  command "python setup.py install"
  creates "/opt/graphite/lib/carbon-#{node.graphite.carbon.version}-py2.6.egg-info"
  cwd "/usr/src/carbon-#{node.graphite.carbon.version}"
end

template "/opt/graphite/conf/carbon.conf" do
  variables( :line_receiver_interface => node[:graphite][:carbon][:line_receiver_interface],
             :pickle_receiver_interface => node[:graphite][:carbon][:pickle_receiver_interface],
             :cache_query_interface => node[:graphite][:carbon][:cache_query_interface] )
  notifies :restart, "service[carbon-cache.service]"
end

template "/opt/graphite/conf/storage-schemas.conf" do
  mode "0644"
end

template "/opt/graphite/conf/storage-aggregation.conf" do
  mode "0644"
end

execute "reload-systemd" do
  command "systemctl --system daemon-reload"
  action :nothing
end

template "/etc/systemd/system/carbon-cache.service" do
  mode "0640"
  source "carbon-cache.service.erb"
  notifies :run, "execute[reload-systemd]", :immediately
end

service "carbon-cache.service" do
  action [:start, :enable]
  supports :status => true, :restart => true
  provider Chef::Provider::Service::Systemd
end
