directory "/opt/graphite_proxy" do
  action :create
end

template "/opt/graphite_proxy/proxy.py" do
  source "proxy.py"
end

execute "reload-systemd" do
  command "systemctl --system daemon-reload"
  action :nothing
end

template "/etc/systemd/system/graphite_proxy.service" do
  mode "0640"
  source "graphite_proxy.service.erb"
  notifies :run, "execute[reload-systemd]", :immediately
end

service "graphite_proxy.service" do
  action [:start, :enable]
  supports :status => true, :restart => true
  provider Chef::Provider::Service::Systemd
end

file "/etc/iptables.d/graphite_proxy" do
  content "
*filter
-A INPUT -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT
COMMIT
"
  notifies :restart, "service[iptables.service]", :immediately
end
