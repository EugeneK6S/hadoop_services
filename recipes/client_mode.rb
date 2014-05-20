#
# Cookbook Name:: hadoop_services
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "java_wrapper"

include_recipe "hadoop::default"

require 'resolv'
			
tmp_hosts = node['hadoop']['hdfs_site']['dfs.namenode.http-address.mycluster.nn1']
dns_name = tmp_hosts[0..-7]
id_addr = Resolv.getaddress(dns_name)

ruby_block "add_to_hosts" do
	block do
		File.open('/etc/hosts', 'a') { |f| f.write("#{id_addr} mycluster") }
	end
	not_if { File.open('/etc/hosts').lines.any?{|line| line.include?("#{id_addr}")} }
end

