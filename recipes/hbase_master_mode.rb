node.set['hadoop']['hbase_site']['hbase.rootdir'] = node['hadoop']['hdfs_site']['dfs.namenode.rpc-address.mycluster.nn1']
node.set['hadoop']['hbase_site']['hbase.zookeeper.quorum'] = node['hadoop']['core_site']['ha.zookeeper.quorum']

chef_gem "chef-rewind"
require 'chef/rewind'

include_recipe "hadoop::hbase_master"

rewind "service[hbase-master]" do	
	supports :status => true, :start => true, :stop => true, :restart => true
	action [:enable, :start]
end