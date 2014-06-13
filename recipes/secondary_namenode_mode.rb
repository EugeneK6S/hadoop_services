#
# Cookbook Name:: hadoop_services
# Recipe:: secondary_namenode_mode
#
# Copyright 2014, EPAM Systems
#
# All rights reserved - Do Not Redistribute
#

chef_gem "chef-rewind"
require 'chef/rewind'
require 'resolv'

## Setting attributes needed for config generation based on roles

if Chef::Config[:solo]
  	Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else
	ruby_block "generate_config" do
		block do
			act_nn_array = Array.new
			search(:node, "role:hadoop-namenode AND hadoop_services_is_active_nn:true AND project:#{node['project']}").each do |n|
			# partial_search(:node, "role:hadoop-namenode AND hadoop_services_is_active_nn:true AND project:#{node['project']}", :keys => { 'fqdn' => [ 'fqdn' ] }).each do |n|
				act_nn_array << n['fqdn']
				act_nn_array.each do |nn1|
					nn1_edit = "hdfs:"
					node.set['hadoop']['hdfs_site']['dfs.namenode.rpc-address.mycluster.nn1'] = nn1 + ":8020"
					node.set['hadoop']['hdfs_site']['dfs.namenode.http-address.mycluster.nn1'] = nn1 + ":50070"
					node.set['hadoop']['core_site']['fs.defaultFS'] = "hdfs://" + nn1 + ":8020"
					node.set['hadoop_services']['ha.zookeeper.quorum.part1'] = nn1
					Chef::Log.info("ZK node 1 is #{node['hadoop_services']['ha.zookeeper.quorum.part1']}")
				end
			end

			stndby_nn_array = Array.new
			search(:node, "role:hadoop-namenode AND hadoop_services_is_standby_nn:true AND project:#{node['project']}").each do |n|
				stndby_nn_array << n['fqdn']
				stndby_nn_array.each do |nn2|
					node.set['hadoop']['hdfs_site']['dfs.namenode.rpc-address.mycluster.nn2'] = nn2 + ":8020"
					node.set['hadoop']['hdfs_site']['dfs.namenode.http-address.mycluster.nn2'] = nn2 + ":50070"
					node.set['hadoop_services']['ha.zookeeper.quorum.part2'] = nn2
					Chef::Log.info("ZK node 2 is #{node['hadoop_services']['ha.zookeeper.quorum.part2']}")
				end
			end

			node.set['hadoop']['core_site']['ha.zookeeper.quorum'] =  "#{node['hadoop_services']['ha.zookeeper.quorum.part1']}" + ',' + "#{node['hadoop_services']['ha.zookeeper.quorum.part2']}"

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

			node.save
		end
	end
end

if ( node['hadoop_services']['already_secondary_nn'] ) then

	Chef::Log.warn ("!!! U already have ResourceManager running !!!")

else 

	include_recipe "java_wrapper"

	include_recipe "hadoop::hadoop_hdfs_secondarynamenode"


    hosts_array = Array.new
	search(:node, "role:hadoop-slave AND project:#{node['project']}").each do |n|
        hosts_array << n['fqdn']
        node.set['hadoop_services']['slaves'] = hosts_array
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

	cookbook_file "commons-logging.properties" do
			path "#{node['hadoop']['hadoop_env']['hadoop_conf_dir']}/commons-logging.properties"
		mode "0755"
	    owner "hdfs"
	    group "hdfs"
			action :create_if_missing
	end

	rewind "service[hadoop-hdfs-secondarynamenode]" do
		action :reload
	end

	ruby_block "report_resourcemanager_status" do
	    block do
			node.set['hadoop_services']['already_secondary_nn'] = true
	    end
	    action :nothing
	end
end