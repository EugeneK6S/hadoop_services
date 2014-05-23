chef_gem "chef-rewind"
require 'chef/rewind'
require 'resolv'

## Setting attributes needed for config generation based on roles

act_nn_array = Array.new
search(:node, "role:hadoop-namenode AND hadoop_services_is_active_nn:true AND project:#{node['project']}").each do |n|
	act_nn_array << n['fqdn']
	act_nn_array.each do |nn1|
		node.set['hadoop']['hdfs_site']['dfs.namenode.rpc-address.mycluster.nn1'] = nn1 + ":8020"
		node.set['hadoop']['hdfs_site']['dfs.namenode.http-address.mycluster.nn1'] = nn1 + ":50070"
		node.set['hadoop']['core_site']['fs.defaultFS'] = nn1 + ":8020"
		node.set['hadoop_services']['ha.zookeeper.quorum.part1'] = nn1
	end
end

stndby_nn_array = Array.new
search(:node, "role:hadoop-namenode AND hadoop_services_is_standby_nn:true AND project:#{node['project']}").each do |n|
	stndby_nn_array << n['fqdn']
	stndby_nn_array.each do |nn2|
		node.set['hadoop']['hdfs_site']['dfs.namenode.rpc-address.mycluster.nn2'] = nn2 + ":8020"
		node.set['hadoop']['hdfs_site']['dfs.namenode.http-address.mycluster.nn2'] = nn2 + ":50070"
		node.set['hadoop_services']['ha.zookeeper.quorum.part2'] = nn2
	end
end

node.set['hadoop']['core_site']['ha.zookeeper.quorum'] = node['hadoop_services']['ha.zookeeper.quorum.part1'] + ',' + node.set['hadoop_services']['ha.zookeeper.quorum.part2']

rm_array = Array.new
search(:node, "role:hadoop-resourcemanager AND project:#{node['project']}").each do |n|
	rm_array << n['fqdn']
	rm_array.each do |rm|
		node.set['hadoop']['yarn_site']['yarn.resourcemanager.address'] = rm + ":8032"
		node.set['hadoop']['yarn_site']['yarn.resourcemanager.admin.address'] = rm + ":8033"
		node.set['hadoop']['yarn_site']['yarn.resourcemanager.hostname'] = rm
		node.set['hadoop']['yarn_site']['yarn.resourcemanager.resource-tracker.address'] = rm + ":8031"
		node.set['hadoop']['yarn_site']['yarn.resourcemanager.scheduler.address'] = rm + ":8030"
		node.set['hadoop']['yarn_site']['yarn.resourcemanager.webapp.address'] = rm + ":8088"
		node.set['hadoop']['yarn_site']['yarn.resourcemanager.webapp.https.address'] = rm + ":8090"
	end
end


if ( File.exists?("/var/run/hadoop-hdfs/hadoop-hdfs-datanode.pid") or node['hadoop_services']['already_datanode'] ) then

	Chef::Log.warn ("!!! U already have DataNode running !!!")

	tmp_hosts = node['hadoop']['hdfs_site']['dfs.namenode.http-address.mycluster.nn1']
	dns_name = tmp_hosts[0..-7]
	id_addr = Resolv.getaddress(dns_name)

	ruby_block "add_to_hosts" do
		block do
			File.open('/etc/hosts', 'a') { |f| f.write("#{id_addr} mycluster") }
		end
		not_if { File.open('/etc/hosts').lines.any?{|line| line.include?("#{id_addr}")} }
	end

	include_recipe "hadoop::default"

else

	include_recipe "java_wrapper"

	include_recipe "hadoop::hadoop_hdfs_datanode"

	# directory "#{node['hadoop']['hadoop_env']['hadoop_pid_dir']}" do
	#   mode "0755"
	#   owner "hdfs"
	#   group "hdfs"
	#   action :create
	#   recursive true
	# end

	# cookbook_file "hadoop-metrics.properties" do
	#   path "#{node['hadoop']['hadoop_env']['hadoop_conf_dir']}/hadoop-metrics.properties"
	#   action :create
	#   mode "0755"
	#   owner "hdfs"
	#   group "hdfs"
	# end


	## Edit /etc/hosts file		
	tmp_hosts = node['hadoop']['hdfs_site']['dfs.namenode.http-address.mycluster.nn1']
	dns_name = tmp_hosts[0..-7]
	id_addr = Resolv.getaddress(dns_name)

	ruby_block "add_to_hosts" do
		block do
			File.open('/etc/hosts', 'a') { |f| f.write("#{id_addr} mycluster") }
		end
		not_if { File.open('/etc/hosts').lines.any?{|line| line.include?("#{id_addr}")} }
	end

	cookbook_file "container-executor.cfg" do
	  path "#{node['hadoop']['hadoop_env']['hadoop_conf_dir']}/container-executor.cfg"
	  action :create
	  mode "0755"
	  owner "hdfs"
	  group "hdfs"
	end

	cookbook_file "taskcontroller.cfg" do
	  path "#{node['hadoop']['hadoop_env']['hadoop_conf_dir']}/taskcontroller.cfg"
	  action :create
	  mode "0755"
	  owner "hdfs"
	  group "hdfs"
	end


	## Edit slaves file
 #    hosts_array = Array.new
 #    search(:node, "role:hadoop-slave AND project:#{node['project']}").each do |n|
 #        hosts_array << n['fqdn']
 #        node.set['hadoop_services']['slaves'] = hosts_array
 #    end

	# myVars = { :slavenode => node['hadoop_services']['slaves'] }

	# template "#{node['hadoop']['hadoop_env']['hadoop_conf_dir']}/slaves" do
	#     source "slaves.erb"
	# 	mode "0755"
	#     owner "hdfs"
	#     group "hdfs"
	#     action :create
	#     variables myVars
	# 	notifies :run, 'execute[hdfs-chown-dirs]', :immediately
	# end

	execute "hdfs-chown-dirs" do
		command <<-EOF 
			chown -R hdfs:hdfs #{node['hadoop']['hadoop_env']['hadoop_prefix']}-* 
			chown -R hdfs:hdfs #{node['hadoop']['conf_dir']} 
			chown -R hdfs:hdfs /tmp/hadoop-*
			chown -R hdfs:hdfs #{node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.dir']}
	  		chown -R zookeeper:zookeeper #{node['zookeeper']['zoocfg']['dataLogDir']}
	  		chown -R hdfs:hdfs #{node['hadoop']['core_site']['hadoop.tmp.dir']}
	  		chown -R hdfs:hdfs #{node['hadoop']['hadoop_env']['hadoop_log_dir']}
	  		chown -R hdfs:hdfs #{node['hadoop']['hadoop_env']['hadoop_mapred_home']}
		EOF
		action :run
		group "root"
		user "root"
	end

	rewind "service[hadoop-hdfs-datanode]" do
		supports :status => true, :start => true, :stop => true, :restart => true
		action [:enable, :start]
	end

	ruby_block "report_datanode_status" do
	    block do
			node.set['hadoop_services']['already_datanode'] = true
	    end
	    action :nothing
	end

end