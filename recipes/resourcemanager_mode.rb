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

if ( File.exists?("/run/hadoop-yarn/yarn-yarn-resourcemanager.pid") or node['hadoop_services']['already_resourcemanager'] ) then

	Chef::Log.warn ("!!! U already have ResourceManager running !!!")

	include_recipe "hadoop::default"


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
				
	tmp_hosts = node['hadoop']['hdfs_site']['dfs.namenode.http-address.mycluster.nn1']
	dns_name = tmp_hosts[0..-7]
	id_addr = Resolv.getaddress(dns_name)

	ruby_block "add_to_hosts" do
		block do
			File.open('/etc/hosts', 'a') { |f| f.write("#{id_addr} mycluster") }
		end
		not_if { File.open('/etc/hosts').lines.any?{|line| line.include?("#{id_addr}")} }
	end

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