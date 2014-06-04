include_recipe "nfs"

tmp = node['hadoop']['hdfs_site']['dfs.namenode.shared.edits.dir']
dfs_shared_edit = tmp[7..-1]
Chef::Log.info("#{dfs_shared_edit}")

directory "#{dfs_shared_edit}" do
  	mode "0755"
  	owner "root"
  	group "root"
  	action :create
  	recursive true
end


if Chef::Config[:solo]
  	Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else

	search(:node, "role:hadoop-nfs-share").each do |n|

		mount "#{dfs_shared_edit}" do
			device "#{n['ipaddress']}:#{node['hadoop_services']['nfs_dir']}"
			fstype "nfs"
	    	options "rw"
			action [:mount, :enable]
			only_if { ::File.exist?("#{dfs_shared_edit}") }
		end

	end
end