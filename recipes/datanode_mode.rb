chef_gem "chef-rewind"
require 'chef/rewind'
require 'resolv'

if ( File.exists?("/var/run/hadoop-hdfs/hadoop-hdfs-datanode.pid") or node['hadoop_services']['already_datanode'] ) then

	Chef::Log.warn ("!!! U already have DataNode running !!!")

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


	myVars = { :slavenode => node['hadoop_services']['slaves'] }

	template "#{node['hadoop']['hadoop_env']['hadoop_conf_dir']}/slaves" do
	    source "slaves.erb"
		mode "0755"
	    owner "hdfs"
	    group "hdfs"
	    action :create
	    variables myVars
		notifies :run, 'execute[hdfs-chown-dirs]', :immediately
	end

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