hadoop_services Cookbook
========================
This cookbook is THE GOD of HADOOP cookbooks, hahaha.
It has recipies to install 2 NameNodes (Active+Standby HA fail-over), YARN stuff, and soon - Hbase and Pig.

Requirements
------------
Requires Hadoop community cookbook, v.1.0.1 - tested.

Attributes
----------
To set up next attributes before launch:

node['hadoop_services']['is_active_nn'] - choose your active namenode;
node['project'] - unique name for your project, like "hadoop_user_cluster_v1"
node['hadoop']['core_site']['ha.zookeeper.quorum'] = comma-separated list of your NameNodes
node['hadoop']['hdfs_site']['dfs.namenode.rpc-address.mycluster.nn1'] = active NN, FQDN:8020
node['hadoop']['hdfs_site']['dfs.namenode.rpc-address.mycluster.nn2'] = standby NN, FQDN:8020
node['hadoop']['hdfs_site']['dfs.namenode.http-address.mycluster.nn1'] = active NN, FQDN:50070 
node['hadoop']['hdfs_site']['dfs.namenode.http-address.mycluster.nn2'] = standby NN, FQDN:50070
node['hadoop']['yarn_site']['yarn.resourcemanager.address'] = ResourceManager FQDN:8032
node['hadoop']['yarn_site']['yarn.resourcemanager.admin.address'] = ResourceManager FQDN:8033
node['hadoop']['yarn_site']['yarn.resourcemanager.hostname'] = ResourceManager FQDN
node['hadoop']['yarn_site']['yarn.resourcemanager.resource-tracker.address' = ResourceManager FQDN:8031
node['hadoop']['yarn_site']['yarn.resourcemanager.scheduler.address'] = ResourceManager FQDN:8030
node['hadoop']['yarn_site']['yarn.resourcemanager.webapp.address'] = ResourceManager FQDN:8088
node['hadoop']['yarn_site']['yarn.resourcemanager.webapp.https.address'] = ResourceManager FQDN:8090

ATTRIBUTES should be setup in cookbook, currently CLI won't support attributes with . in name.

Usage
-----
Roles!

0. PREREQUSITE in case of NFS used for HA: or2setp -i node_ID -t "ep_chefrole=hadoop-nfs-share" 

1. for Standby NN: or2setp -i node_ID -t "ep_chefrole=hadoop-namenode" -t "ep_chefattributes=project=hadoopv3,hadoop_services.slaves=slave_id+slave_id2+...slave_idN"

2. for Active NN: or2setp -i node_ID -t "ep_chefrole=hadoop-namenode" -t "ep_chefattributes=project=hadoopv3,hadoop_services.is_active_nn=true,hadoop_services.slaves=slave_id+slave_id2+...slave_idN"

if no HA failover -> 

3. for Secondary NN: or2setp -i node_ID -t "ep_chefrole=hadoop-secondary-namenode" -t "ep_chefattributes=project=hadoopv3,hadoop_services.slaves=slave_id+slave_id2+...slave_idN"

Next step ->

3. for ResourceManager: or2setp -i node_ID -t "ep_chefrole=hadoop-resourcemanager" -t "ep_chefattributes=project=hadoopv3,hadoop_services.slaves=slave_id+slave_id2+...slave_idN"

4. for Slave: or2setp -i node_ID -t "ep_chefrole=hadoop-slave" -t "ep_chefattributes=project=hadoopv3,hadoop_services.slaves=slave_id+slave_id2+...slave_idN"


Contributing
------------
TODO: (optional) If this is a public cookbook, detail the process for contributing. If this is a private cookbook, remove this section.

e.g.
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: Ievgen_Kabanets@epam.com
