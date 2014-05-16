include_recipe "nfs::server"

directory "#{node['hadoop_services']['nfs_dir']}" do
  mode "0755"
  owner "root"
  group "root"
  action :create
  recursive true
end

case node['platform_family']
when "debian"

	template "/etc/exports" do
	  source "exports.erb"
	  owner "root"
	  group "root"
	  mode "0644"
	  variables ({ :nfs_dir => node['hadoop_services']['nfs_dir'] })
	  notifies :restart, 'service[nfs-kernel-server]'
	end
	
	service "nfs-kernel-server" do
	  supports :status => true, :start => true, :stop => true, :restart => true
	  action :start
	end

when "rhel"

	template "/etc/exports" do
	  source "exports.erb"
	  owner "root"
	  group "root"
	  mode "0644"
	  variables ({ :nfs_dir => node['hadoop_services']['nfs_dir'] })
	  notifies :restart, 'service[nfs]'
	end

	service "nfs" do
	  supports :status => true, :start => true, :stop => true, :restart => true
	  action :start
	end

end


