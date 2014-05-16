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

if ( File.exists?("/run/hadoop-yarn/yarn-yarn-resourcemanager.pid") or node['hadoop_services']['already_resourcemanager'] ) then

	Chef::Log.warn ("!!! U already have ResourceManager running !!!")

else 

	include_recipe "java_wrapper"

	include_recipe "hadoop::hadoop_yarn_resourcemanager"

	cookbook_file "commons-logging.properties" do
  		path "#{node['hadoop']['hadoop_env']['hadoop_conf_dir']}/commons-logging.properties"
		mode "0755"
	    owner "hdfs"
	    group "hdfs"
  		action :create_if_missing
	end

	rewind "service[hadoop-yarn-resourcemanager]" do
		action :reload
	end

	ruby_block "report_resourcemanager_status" do
	    block do
			node.set['hadoop_services']['already_resourcemanager'] = true
	    end
	    action :nothing
	end

end