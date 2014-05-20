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

if ( node['hadoop_services']['already_secondary_nn'] ) then

	Chef::Log.warn ("!!! U already have ResourceManager running !!!")

else 

	include_recipe "java_wrapper"

	include_recipe "hadoop::hadoop_hdfs_secondarynamenode"


    hosts_array = Array.new
    search(:node, "role:hadoop-slave").each do |n|
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