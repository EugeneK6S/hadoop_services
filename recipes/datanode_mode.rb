chef_gem "chef-rewind"
require 'chef/rewind'

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