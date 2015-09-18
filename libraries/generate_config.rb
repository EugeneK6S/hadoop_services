module HadoopMod
  
	def generate_config()
		
		if Chef::Config[:solo]
		  	Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
		else
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
					node.set['hadoop']['mapred_site']['mapreduce.jobhistory.address'] = nn1 + ":10020"
					node.set['hadoop']['mapred_site']['mapreduce.jobhistory.webapp.address'] = nn1 + ":19888"
					Chef::Log.info("ZK Quorum node #1 is #{node['hadoop_services']['ha.zookeeper.quorum.part1']}")
				end
			end

			stndby_nn_array = Array.new
			search(:node, "role:hadoop-namenode AND hadoop_services_is_standby_nn:true AND project:#{node['project']}").each do |n|
				stndby_nn_array << n['fqdn']
				stndby_nn_array.each do |nn2|
					node.set['hadoop']['hdfs_site']['dfs.namenode.rpc-address.mycluster.nn2'] = nn2 + ":8020"
					node.set['hadoop']['hdfs_site']['dfs.namenode.http-address.mycluster.nn2'] = nn2 + ":50070"
					node.set['hadoop_services']['ha.zookeeper.quorum.part2'] = nn2
					Chef::Log.info("ZK Quorum node #2 is #{node['hadoop_services']['ha.zookeeper.quorum.part2']}")
				end
			end

			#node.set['hadoop']['core_site']['ha.zookeeper.quorum'] =  "#{node['hadoop_services']['ha.zookeeper.quorum.part1']}" + ',' + "#{node['hadoop_services']['ha.zookeeper.quorum.part2']}"
			node.set['hadoop']['core_site']['ha.zookeeper.quorum'] =  node['hadoop_services']['ha.zookeeper.quorum.part1'] + ',' + node['hadoop_services']['ha.zookeeper.quorum.part2']

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

	def fix_yarn_config()
		File.open('/etc/hadoop/conf.chef/yarn-env.sh', 'a')  { |f|
			f << "if [ \"$JAVA_HOME\" != \"\" ]; then\n"
			f << "JAVA_HOME=$JAVA_HOME\n"
			f << "fi\n"

			f << "if [ \"$JAVA_HOME\" = \"\" ]; then\n"
			f << "echo \"Error: JAVA_HOME is not set.\"\n"
			f << "fi\n"

			f << "JAVA=$JAVA_HOME/bin/java\n"
			f << "JAVA_HEAP_MAX=-Xmx1000m\n"
			f << "YARN_HEAPSIZE=1024\n"

			f << "if [ \"$YARN_HEAPSIZE\" != \"\" ]; then\n"
			f << "JAVA_HEAP_MAX=\"-Xmx\"\"$YARN_HEAPSIZE\"\"m\"\n"
			f << "fi\n"
			
			f << "IFS=\n"

			f << "if [ \"$YARN_LOG_DIR\" = \"\" ]; then\n"
			f << "YARN_LOG_DIR=\"$HADOOP_YARN_HOME/logs\"\n"
			f << "fi\n"

			f << "if [ \"$YARN_LOGFILE\" = \"\" ]; then\n"
			f << "YARN_LOGFILE=\'yarn.log\'\n"
			f << "fi\n"

			f << "if [ \"$YARN_POLICYFILE\" = \"\" ]; then\n"
			f << "YARN_POLICYFILE=\"hadoop-policy.xml\"\n"
			f << "fi\n"

			f << "unset IFS\n"

			f << "YARN_OPTS=\"$YARN_OPTS -Dhadoop.log.dir=$YARN_LOG_DIR\"\n"
			f << "YARN_OPTS=\"$YARN_OPTS -Dyarn.log.dir=$YARN_LOG_DIR\"\n"
			f << "YARN_OPTS=\"$YARN_OPTS -Dhadoop.log.file=$YARN_LOGFILE\"\n"
			f << "YARN_OPTS=\"$YARN_OPTS -Dyarn.log.file=$YARN_LOGFILE\"\n"
			f << "YARN_OPTS=\"$YARN_OPTS -Dyarn.home.dir=$YARN_COMMON_HOME\"\n"
			f << "YARN_OPTS=\"$YARN_OPTS -Dyarn.id.str=$YARN_IDENT_STRING\"\n"
			f << "YARN_OPTS=\"$YARN_OPTS -Dhadoop.root.logger=${YARN_ROOT_LOGGER:-INFO,console}\"\n"
			f << "YARN_OPTS=\"$YARN_OPTS -Dyarn.root.logger=${YARN_ROOT_LOGGER:-INFO,console}\"\n"

			f << "if [ \"x$JAVA_LIBRARY_PATH\" != \"x\" ]; then\n"
			f << "YARN_OPTS=\"$YARN_OPTS -Djava.library.path=$JAVA_LIBRARY_PATH\"\n"
			f << "fi\n"

			f << "YARN_OPTS=\"$YARN_OPTS -Dyarn.policy.file=$YARN_POLICYFILE\"\n"
			f.close
		}
	end

end