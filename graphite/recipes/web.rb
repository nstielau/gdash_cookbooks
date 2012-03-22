

package "httpd"
package "mod_python"

package "pycairo-devel"
package "Django"
package "python-memcached"
package "rrdtool-python"

# Python libraries.
['django-tagging==0.3.1'].each do |package_name|
  execute "install_#{package_name}" do
    command "pip-python install #{package_name}"
  end
end

remote_file "/usr/src/graphite-web-#{node.graphite.graphite_web.version}.tar.gz" do
  source node.graphite.graphite_web.uri
  checksum node.graphite.graphite_web.checksum
end

execute "untar graphite-web" do
  command "tar xzf graphite-web-#{node.graphite.graphite_web.version}.tar.gz"
  creates "/usr/src/graphite-web-#{node.graphite.graphite_web.version}"
  cwd "/usr/src"
end

remote_file "/usr/src/graphite-web-#{node.graphite.graphite_web.version}/webapp/graphite/storage.py.patch" do
  source "http://launchpadlibrarian.net/65094495/storage.py.patch"
  checksum "8bf57821"
end

execute "install graphite-web" do
  command "python setup.py install"
  creates "/opt/graphite/webapp/graphite_web-#{node.graphite.graphite_web.version}-py2.6.egg-info"
  cwd "/usr/src/graphite-web-#{node.graphite.graphite_web.version}"
end

template "/etc/httpd/conf.d/graphite.conf" do
  source "graphite-vhost.conf.erb"
end

directory "/opt/graphite/storage/log/webapp" do
  owner "apache"
  group "apache"
end

directory "/opt/graphite/storage" do
  owner "apache"
  group "apache"
end

cookbook_file "/opt/graphite/storage/graphite.db" do
  owner "apache"
  group "apache"
  action :create_if_missing
end

service "httpd.service" do
  action [:start, :enable]
  supports :status => true, :restart => true
  provider Chef::Provider::Service::Systemd
end
