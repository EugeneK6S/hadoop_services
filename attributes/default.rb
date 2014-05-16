##############################
# Attributes for java_wrapper
##############################

default['java']['install_flavor'] = "oracle"
default['java']['jdk_version'] = '6'

###################################################################################################################################################################################################
# Attributes for instance's roles in cluster
###################################################################################################################################################################################################

default['hadoop_services']['is_active_nn'] = false
default['hadoop_services']['already_namenode'] = false
default['hadoop_services']['already_resourcemanager'] = false
default['hadoop_services']['already_datanode'] = false
default['hadoop_services']['already_nodemanager'] = false
default['hadoop_services']['already_secondary_nn'] = false

default['hadoop_services']['hadoop_config_prefix'] = "/etc/hadoop"
default['hadoop_services']['ssh']['status'] = "need_generate"
default['hadoop_services']['ssh']['private_key'] = nil
default['hadoop_services']['ssh']['public_key'] = nil
default['hadoop_services']['slaves'] = nil
default['hadoop_services']['nfs_dir'] = "/usr/share/hadoop/shared_edits"

case node['platform_family']
when "debian"
	default['nfs']['packages'] = %w(portmap nfs-common)
when "rhel"
	default['nfs']['packages'] = %w(nfs-utils portmap nfs-common)
end

###################################################################################################################################################################################################
##
## Attributes for different Hadoop Cluster roles!
## RTFM: http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/ClusterSetup.html
##
###################################################################################################################################################################################################

#################################################################################################################################################################################################################################
# hadoop-env.sh settings
#################################################################################################################################################################################################################################

default['hadoop']['hadoop_env']['hadoop_log_dir'] = "/var/log/hadoop" #or "/var/log/hadoop/$USER"
default['hadoop']['hadoop_env']['hadoop_mapred_log_dir'] = "/var/log/hadoop-mapreduce/" #or "/var/log/hadoop-mapreduce/$USER"
default['hadoop']['hadoop_env']['hadoop_secure_dn_log_dir'] = "/var/log/hadoop/$HADOOP_SECURE_DN_USER"

case node['platform_family']
when "debian"
	default['hadoop']['hadoop_env']['java_home'] = "/usr/lib/jvm/java-6-oracle-amd64"
when "rhel"
	default['hadoop']['hadoop_env']['java_home'] = "/usr/lib/jvm/java/"
end


default['hadoop']['hadoop_env']['hadoop_libexec_dir'] = "/usr/lib/hadoop/libexec"
default['hadoop']['hadoop_env']['hadoop_prefix'] = "/usr/lib/hadoop"
default['hadoop']['hadoop_env']['hadoop_conf_dir'] = "/etc/hadoop/conf.chef"
default['hadoop']['hadoop_env']['hadoop_opts'] = "-Djava.net.preferIPv4Stack=true $HADOOP_OPTS"
# default['hadoop']['hadoop_env']['hadoop_hdfs_home'] = "/usr/lib/hadoop"
default['hadoop']['hadoop_env']['hadoop_mapred_home'] = "/usr/lib/hadoop-mapreduce"
default['hadoop']['hadoop_env']['hadoop_classpath'] = "${HADOOP_CLASSPATH}${JAVA_JDBC_LIBS}:/usr/lib/hadoop-mapreduce/*"

default['hadoop']['hadoop_env']['hadoop_namenode_opts'] = "-Dcom.sun.management.jmxremote $HADOOP_NAMENODE_OPTS"
#default['hadoop']['hadoop_env']['hadoop_namenode_opts'] = "-server -XX:ParallelGCThreads=8 -XX:+UseConcMarkSweepGC -XX:ErrorFile=/var/log/hadoop/$USER/hs_err_pid%p.log -XX:NewSize=200m -XX:MaxNewSize=200m -Xloggc:/var/log/hadoop/$USER/gc.log-`date +'%Y%m%d%H%M'` -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -Xms1024m -Xmx1024m -Dhadoop.security.logger=INFO,DRFAS -Dhdfs.audit.logger=INFO,DRFAAUDIT ${HADOOP_NAMENODE_OPTS}"
default['hadoop']['hadoop_env']['hadoop_secondarynamenode_opts'] = "-Dcom.sun.management.jmxremote $HADOOP_SECONDARYNAMENODE_OPTS"
#default['hadoop']['hadoop_env']['hadoop_secondarynamenode_opts'] = "-server -XX:ParallelGCThreads=8 -XX:+UseConcMarkSweepGC -XX:ErrorFile=/var/log/hadoop/$USER/hs_err_pid%p.log -XX:NewSize=200m -XX:MaxNewSize=200m -Xloggc:/var/log/hadoop/$USER/gc.log-`date +'%Y%m%d%H%M'` -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps ${HADOOP_NAMENODE_INIT_HEAPSIZE} -Xmx1024m -Dhadoop.security.logger=INFO,DRFAS -Dhdfs.audit.logger=INFO,DRFAAUDIT ${HADOOP_SECONDARYNAMENODE_OPTS}"
default['hadoop']['hadoop_env']['hadoop_datanode_opts'] = "-Dcom.sun.management.jmxremote $HADOOP_DATANODE_OPTS"
#default['hadoop']['hadoop_env']['hadoop_datanode_opts'] = "-Xmx1024m -Dhadoop.security.logger=ERROR,DRFAS ${HADOOP_DATANODE_OPTS}"
default['hadoop']['hadoop_env']['hadoop_balancer_opts'] = "-Dcom.sun.management.jmxremote $HADOOP_BALANCER_OPTS"
#default['hadoop']['hadoop_env']['hadoop_balancer_opts'] = "-server -Xmx1024m ${HADOOP_BALANCER_OPTS}"
default['hadoop']['hadoop_env']['hadoop_jobtracker_opts'] = "-Dcom.sun.management.jmxremote $HADOOP_JOBTRACKER_OPTS"
#default['hadoop']['hadoop_env']['hadoop_jobtracker_opts'] = "-server -XX:ParallelGCThreads=8 -XX:+UseConcMarkSweepGC -XX:ErrorFile=/var/log/hadoop/$USER/hs_err_pid%p.log -XX:NewSize=200m -XX:MaxNewSize=200m -Xloggc:/var/log/hadoop/$USER/gc.log-`date +'%Y%m%d%H%M'` -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -Xmx1024m -Dhadoop.security.logger=INFO,DRFAS -Dmapred.audit.logger=INFO,MRAUDIT -Dhadoop.mapreduce.jobsummary.logger=INFO,JSA ${HADOOP_JOBTRACKER_OPTS}"
default['hadoop']['hadoop_env']['yarn_opts'] = "-Xms825955249 -Xmx825955249 -Djava.net.preferIPv4Stack=true $YARN_OPTS"
default['hadoop']['hadoop_env']['hadoop_tasktracker_opts'] = "-server -Xmx1024m -Dhadoop.security.logger=ERROR,console -Dmapred.audit.logger=ERROR,console ${HADOOP_TASKTRACKER_OPTS}"
default['hadoop']['hadoop_env']['hadoop_client_opts'] = "-Xms268435456 -Xmx268435456 -Djava.net.preferIPv4Stack=true $HADOOP_CLIENT_OPTS"
#default['hadoop']['hadoop_env']['hadoop_client_opts'] = "-Xmx${HADOOP_HEAPSIZE}m $HADOOP_CLIENT_OPTS"
default['hadoop']['hadoop_env']['hadoop_ssh_opts'] = "-o ConnectTimeout=5 -o SendEnv=HADOOP_CONF_DIR"

default['hadoop']['hadoop_env']['hadoop_slaves'] = nil
default['hadoop']['hadoop_env']['hadoop_home_warn_suppress'] = '1'
default['hadoop']['hadoop_env']['jsvc_home'] = "/usr/lib/bigtop-utils"# Hadoop Configuration Directory = if env var set that can cause problems
default['hadoop']['hadoop_env']['hadoop_heapsize'] = "1024"
default['hadoop']['hadoop_env']['hadoop_secure_dn_user'] = "hdfs"
default['hadoop']['hadoop_env']['yarn_resourcemanager_opts'] = "-Dyarn.server.resourcemanager.appsummary.logger=INFO,RMSUMMARY"
default['hadoop']['hadoop_env']['hbase_classpath'] = "`echo $HBASE_CLASSPATH | sed -e \"s|$ZOOKEEPER_CONF:||\"`"
default['hadoop']['hadoop_env']['hbase_opts'] = "-Xmx268435456 -XX:+HeapDumpOnOutOfMemoryError -XX:+UseConcMarkSweepGC -XX:-CMSConcurrentMTEnabled -XX:+CMSIncrementalMode $HBASE_OPTS"
default['hadoop']['hadoop_env']['hadoop_master'] = nil
default['hadoop']['hadoop_env']['hadoop_slave_sleep'] = nil
default['hadoop']['hadoop_env']['hadoop_pid_dir'] = "/var/run/hadoop-hdfs"
default['hadoop']['hadoop_env']['hadoop_secure_dn_pid_dir'] = "/var/run/hadoop-$USER/$HADOOP_SECURE_DN_USER"
default['hadoop']['hadoop_env']['hadoop_mapred_pid_dir'] = "/var/run/hadoop-mapreduce"
default['hadoop']['hadoop_env']['hadoop_ident_string'] = "$USER"
default['hadoop']['hadoop_env']['hadoop_niceness'] = nil
# for Apache Ambari default['hadoop']['hadoop_env']['java_jdbc_libs'] = ""
#default['hadoop']['hadoop_env']['java_library_path'] = "${JAVA_LIBRARY_PATH}:/usr/lib/hadoop/lib/native/Linux-amd64-64"

#################################################################################################################################################################################################################################
# yarn-env.sh settings
#################################################################################################################################################################################################################################

default['hadoop']['yarn_env']['HADOOP_YARN_HOME'] = "/usr/lib/hadoop-yarn"
default['hadoop']['yarn_env']['YARN_LOG_DIR'] = "/var/log/hadoop-yarn"
default['hadoop']['yarn_env']['YARN_PID_DIR'] = "/var/run/hadoop-yarn"
default['hadoop']['yarn_env']['HADOOP_LIBEXEC_DIR'] = "/usr/lib/hadoop/libexec"
default['hadoop']['yarn_env']['JAVA_HOME'] = "/usr/lib/jvm/java-6-oracle-amd64"
default['hadoop']['yarn_env']['HADOOP_YARN_USER'] = "${HADOOP_YARN_USER:-yarn}"
default['hadoop']['yarn_env']['YARN_CONF_DIR'] = '"${YARN_CONF_DIR:-$HADOOP_YARN_HOME/conf}"'
default['hadoop']['yarn_env']['YARN_RESOURCEMANAGER_HEAPSIZE'] = '1024'
default['hadoop']['yarn_env']['YARN_NODEMANAGER_HEAPSIZE'] = '1024'


#################################################################################################################################################################################################################################
# core-site.xml settings
#################################################################################################################################################################################################################################

default['hadoop']['core_site']['fs.defaultFS'] = "hdfs://EVBYMINSD1F0FT1.minsk.epam.com:8020" #or port 8020???
default['hadoop']['core_site']['hadoop.tmp.dir'] = "/etc/hadoop/hadoop_tmp"
default['hadoop']['core_site']['io.file.buffer.size'] = '131072'
default['hadoop']['core_site']['ha.zookeeper.quorum'] = "EVBYMINSD1F0FT1.minsk.epam.com:2181,EVBYMINSD1F10T1.minsk.epam.com:2181"
default['hadoop']['core_site']['hadoop.proxyuser.hcat.hosts'] = "*"
default['hadoop']['core_site']['hadoop.proxyuser.hive.groups'] = "*"
default['hadoop']['core_site']['hadoop.proxyuser.hcat.groups'] = "*"
default['hadoop']['core_site']['hadoop.security.authentication'] = "simple"
default['hadoop']['core_site']['mapreduce.jobtracker.webinterface.trusted'] = true
default['hadoop']['core_site']['io.serializations'] = "org.apache.hadoop.io.serializer.WritableSerialization"
default['hadoop']['core_site']['hadoop.proxyuser.hue.hosts'] = "*"
default['hadoop']['core_site']['ipc.client.idlethreshold'] = '8000'
default['hadoop']['core_site']['ipc.client.connection.maxidletime'] = '30000'
default['hadoop']['core_site']['fs.wos.impl'] = "com.epam.wosfs.WosFileSystem"
default['hadoop']['core_site']['hadoop.security.authorization'] = false
default['hadoop']['core_site']['hadoop.proxyuser.hive.hosts'] = "*"
default['hadoop']['core_site']['ipc.client.connect.max.retries'] = '50'
default['hadoop']['core_site']['hadoop.proxyuser.hue.groups'] = "*"
default['hadoop']['core_site']['fs.trash.interval'] = '360'
default['hadoop']['core_site']['hadoop.proxyuser.oozie.groups'] = "*"
default['hadoop']['core_site']['hadoop.proxyuser.oozie.hosts'] = "*"
default['hadoop']['core_site']['adoop.security.auth_to_local'] = "\nRULE:[2:$1@$0]([rn]m@.*)s/.*/yarn/\nRULE:[2:$1@$0](jhs@.*)s/.*/mapred/\nRULE:[2:$1@$0]([nd]n@.*)s/.*/hdfs/\nRULE:[2:$1@$0](hm@.*)s/.*/hbase/\nRULE:[2:$1@$0](rs@.*)s/.*/hbase/\nDEFAULT"
default['hadoop']['core_site']['io.compression.codecs'] = "org.apache.hadoop.io.compress.GzipCodec,org.apache.hadoop.io.compress.DefaultCodec"

# All Zookeepers here
# default['hadoop']['core_site']['ha.zookeeper.quorum'] = "#{node['fqdn']}:2181"

#################################################################################################################################################################################################################################
# hdfs-site.xml settings
#################################################################################################################################################################################################################################


default['hadoop']['hdfs_site']['dfs.block.access.token.enable'] = true
default['hadoop']['hdfs_site']['dfs.blockreport.initialDelay'] = '120'
default['hadoop']['hdfs_site']['dfs.blocksize'] = '134217728'
default['hadoop']['hdfs_site']['dfs.client.read.shortcircuit.streams.cache.size'] = '4096'
default['hadoop']['hdfs_site']['dfs.cluster.administrators'] = "hdfs"
default['hadoop']['hdfs_site']['dfs.heartbeat.interval'] = '3'
default['hadoop']['hdfs_site']['dfs.hosts.exclude'] = "#{node['hadoop']['hadoop_env']['hadoop_conf_dir']}/dfs.exclude"
default['hadoop']['hdfs_site']['dfs.permissions.enabled'] = true
default['hadoop']['hdfs_site']['dfs.permissions.superusergroup'] = "hdfs"
default['hadoop']['hdfs_site']['dfs.replication'] = '2'
default['hadoop']['hdfs_site']['dfs.replication.max'] = '50'
default['hadoop']['hdfs_site']['dfs.support.append'] = true
default['hadoop']['hdfs_site']['dfs.webhdfs.enabled'] = true
default['hadoop']['hdfs_site']['fs.checkpoint.size'] = '67108864'
default['hadoop']['hdfs_site']['fs.defaultFS'] = "hdfs://mycluster"
default['hadoop']['hdfs_site']['fs.permissions.umask-mode'] = '022'

# -> Configurations for NameNode:
# -> Settings for HA cluster - MANDATORY

#default['hadoop']['hdfs_site']['dfs.namenode.http-address'] = "#{node['fqdn']}:50070"
# default['hadoop']['hdfs_site']['dfs.domain.socket.path'] = "/var/run/hdfs-sockets/dn"
# ?? default['hadoop']['hdfs_site']['dfs.namenode.servicerpc-address'] = "#{node['fqdn']}:8022"


default['hadoop']['hdfs_site']['dfs.ha.namenodes.mycluster'] = "nn1,nn2"
#default['hadoop']['hdfs_site']['dfs.https.address'] = "#{node['fqdn']}:50470"
default['hadoop']['hdfs_site']['dfs.namenode.rpc-address.mycluster.nn1'] = "EVBYMINSD1F0FT1.minsk.epam.com:8020"
default['hadoop']['hdfs_site']['dfs.namenode.rpc-address.mycluster.nn2'] = "EVBYMINSD1F10T1.minsk.epam.com:8020"
default['hadoop']['hdfs_site']['dfs.nameservices'] = "mycluster"
default['hadoop']['hdfs_site']['dfs.namenode.http-address.mycluster.nn1'] = "EVBYMINSD1F0FT1.minsk.epam.com:50070"
default['hadoop']['hdfs_site']['dfs.namenode.http-address.mycluster.nn2'] = "EVBYMINSD1F10T1.minsk.epam.com:50070"
default['hadoop']['hdfs_site']['dfs.namenode.accesstime.precision'] = '0'
default['hadoop']['hdfs_site']['dfs.namenode.avoid.read.stale.datanode'] = true
default['hadoop']['hdfs_site']['dfs.namenode.avoid.write.stale.datanode'] = true
default['hadoop']['hdfs_site']['dfs.namenode.checkpoint.period'] = '21600'
default['hadoop']['hdfs_site']['dfs.namenode.handler.count'] = '100'
default['hadoop']['hdfs_site']['dfs.namenode.hosts'] = nil
default['hadoop']['hdfs_site']['dfs.namenode.hosts.exclude'] = nil
default['hadoop']['hdfs_site']['dfs.namenode.https-address'] = "EVBYMINSD1F0FT1.minsk.epam.com:50470"
default['hadoop']['hdfs_site']['dfs.https.port'] = '50470'
default['hadoop']['hdfs_site']['dfs.namenode.name.dir'] = "#{node['hadoop']['core_site']['hadoop.tmp.dir']}/dfs/name"
default['hadoop']['hdfs_site']['dfs.namenode.name.dir.restore'] = true
default['hadoop']['hdfs_site']['dfs.namenode.safemode.threshold-pct'] = '1.0f'
default['hadoop']['hdfs_site']['dfs.namenode.stale.datanode.interval'] = '30000'
default['hadoop']['hdfs_site']['dfs.namenode.write.stale.datanode.ratio'] = '1.0f'
default['hadoop']['hdfs_site']['dfs.namenode.shared.edits.dir'] = "file:///etc/hadoop/shared_edits"


# -> Settings for HA cluster failover
default['hadoop']['hdfs_site']['dfs.client.failover.proxy.provider'] = "mycluster"
default['hadoop']['hdfs_site']['dfs.ha.fencing.methods'] = "sshfence"
default['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.dir'] = "/var/lib/hadoop-hdfs/.ssh"
default['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.private-key-files'] = "/var/lib/hadoop-hdfs/.ssh/id_rsa"
default['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.public-key-files'] = "/var/lib/hadoop-hdfs/.ssh/id_rsa.pub"
default['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.authorized-key-files'] = "/var/lib/hadoop-hdfs/.ssh/authorized_keys"
default['hadoop']['hdfs_site']['dfs.ha.automatic-failover.enabled'] = true

# Minimal configuration: http://zookeeper.apache.org/doc/r3.4.5/zookeeperStarted.html#sc_InstallingSingleMode
default['zookeeper']['zoocfg']['clientPort'] = '2181'
default['zookeeper']['zoocfg']['dataDir'] = "/var/lib/zookeeper"
default['zookeeper']['zoocfg']['dataLogDir'] = "/var/log/zookeeper"


# -> Settings for Secondary NameNode 

# default['hadoop']['hdfs_site']['dfs.namenode.secondary.http-address'] = "#{node['fqdn']}:50090"
# default['hadoop']['hdfs_site']['dfs.namenode.checkpoint.dir'] = "#{node['hadoop']['core_site']['hadoop.tmp.dir']}/dfs/namesecondary"
# default['hadoop']['hdfs_site']['dfs.namenode.checkpoint.edits.dir'] = "file://${dfs.namenode.checkpoint.dir}"
# default['hadoop']['hdfs_site']['dfs.namenode.checkpoint.txns'] = '1000000'
# default['hadoop']['hdfs_site']['dfs.namenode.checkpoint.check.period'] = '60'
# default['hadoop']['hdfs_site']['dfs.namenode.checkpoint.max-retries'] = '3'
# default['hadoop']['hdfs_site']['dfs.namenode.num.checkpoints.retained'] = '3'
# default['hadoop']['hdfs_site']['dfs.namenode.edit.log.autoroll.multiplier.threshold'] = '2.0'

# -> Configurations for DataNode:
default['hadoop']['hdfs_site']['dfs.data.dir'] = "/hadoop/hdfs/data"
default['hadoop']['hdfs_site']['dfs.datanode.data.dir'] = "/hadoop/hdfs/data,/hadoop/hdfs500"
default['hadoop']['hdfs_site']['dfs.datanode.data.dir.perm'] = '750'
default['hadoop']['hdfs_site']['dfs.datanode.http.address'] = "0.0.0.0:50075"
default['hadoop']['hdfs_site']['dfs.datanode.max.transfer.threads'] = '1024'
default['hadoop']['hdfs_site']['dfs.datanode.address'] = "0.0.0.0:50010"
default['hadoop']['hdfs_site']['dfs.datanode.du.reserved'] = '1073741824'
default['hadoop']['hdfs_site']['dfs.datanode.ipc.address'] = "0.0.0.0:8010"
default['hadoop']['hdfs_site']['dfs.datanode.balance.bandwidthPerSec'] = '6250000'
default['hadoop']['hdfs_site']['dfs.datanode.failed.volumes.tolerated'] = '0'
default['hadoop']['hdfs_site']['dfs.client.domain.socket.data.traffic'] = false
default['hadoop']['hdfs_site']['dfs.client.read.shortcircuit'] = false #I DISABLED IT! Something with sockets "/var/run/hdfs-sockets/dn"
default['hadoop']['hdfs_site']['dfs.client.read.shortcircuit.skip.checksum'] = false
default['hadoop']['hdfs_site']['dfs.client.use.datanode.hostname'] = false
default['hadoop']['hdfs_site']['dfs.datanode.hdfs-blocks-metadata.enabled'] = true

# -> Configurations for JournalNode:
default['hadoop']['hdfs_site']['dfs.journalnode.http-address'] = "0.0.0.0:8480"
default['hadoop']['hdfs_site']['dfs.journalnode.edits.dir'] = "/hadoop/hdfs/journal"


#################################################################################################################################################################################################################################
# yarn-site.xml settings
#################################################################################################################################################################################################################################

# -> Configurations for ResourceManager and NodeManager:

default['hadoop']['yarn_site']['yarn.acl.enable'] = true
default['hadoop']['yarn_site']['yarn.admin.acl'] = "*"
default['hadoop']['yarn_site']['yarn.log-aggregation-enable'] = true
default['hadoop']['yarn_site']['yarn.log.server.url'] = "http://evhubudsd19bc.budapest.epam.com:19888/jobhistory/logs"

# -> Configurations for ResourceManager:
default['hadoop']['yarn_site']['yarn.am.liveness-monitor.expiry-interval-ms'] = '600000'
#default['hadoop']['yarn_site']['yarn.application.classpath'] = "$HADOOP_CLIENT_CONF_DIR,$HADOOP_CONF_DIR,$HADOOP_COMMON_HOME/*,$HADOOP_COMMON_HOME/lib/*,$HADOOP_HDFS_HOME/*,$HADOOP_HDFS_HOME/lib/*,$HADOOP_YARN_HOME/*,$HADOOP_YARN_HOME/lib/*"
default['hadoop']['yarn_site']['yarn.application.classpath'] = "/etc/hadoop/conf,/usr/lib/hadoop/*,/usr/lib/hadoop/lib/*,/usr/lib/hadoop-hdfs/*,/usr/lib/hadoop-hdfs/lib/*,/usr/lib/hadoop-yarn/*,/usr/lib/hadoop-yarn/lib/*,/usr/lib/hadoop-mapreduce/*,/usr/lib/hadoop-mapreduce/lib/*"
default['hadoop']['yarn_site']['yarn.nm.liveness-monitor.expiry-interval-ms'] = '600000'
default['hadoop']['yarn_site']['yarn.nodemanager.resourcemanager.connect.retry_interval.secs'] = nil
default['hadoop']['yarn_site']['yarn.nodemanager.resourcemanager.connect.wait.secs'] = nil
default['hadoop']['yarn_site']['yarn.nodemanager.resourcemanager.minimum.version'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.address'] = "EVBYMINSD1F12T1.minsk.epam.com:8032" #or port 8050???
default['hadoop']['yarn_site']['yarn.resourcemanager.admin.address'] = "EVBYMINSD1F12T1.minsk.epam.com:8033" #or port 8141????
default['hadoop']['yarn_site']['yarn.resourcemanager.admin.client.thread-count'] = '1'
default['hadoop']['yarn_site']['yarn.resourcemanager.am.max-attempts'] = '2'
default['hadoop']['yarn_site']['yarn.resourcemanager.am.max-retries'] = '1'
default['hadoop']['yarn_site']['yarn.resourcemanager.amliveliness-monitor.interval-ms'] = '1000'
default['hadoop']['yarn_site']['yarn.resourcemanager.application-tokens.master-key-rolling-interval-secs'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.client.thread-count'] = '50'
default['hadoop']['yarn_site']['yarn.resourcemanager.cluster-id'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.connect.max-wait.ms'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.connect.retry-interval.ms'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.container-tokens.master-key-rolling-interval-secs'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.container.liveness-monitor.interval-ms'] = '600000'
default['hadoop']['yarn_site']['yarn.resourcemanager.delayed.delegation-token.removal-interval-ms'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.fs.state-store.retry-policy-spec'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.fs.state-store.uri'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.ha.automatic-failover.embedded'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.ha.automatic-failover.enabled'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.ha.automatic-failover.zk-base-path'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.ha.enabled'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.ha.id'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.ha.rm-ids'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.hostname'] = "EVBYMINSD1F12T1.minsk.epam.com"
default['hadoop']['yarn_site']['yarn.resourcemanager.keytab'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.max-completed-applications'] = '10000'
default['hadoop']['yarn_site']['yarn.resourcemanager.nm.liveness-monitor.interval-ms'] = '1000'
default['hadoop']['yarn_site']['yarn.resourcemanager.nodemanager.minimum.version'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.nodemanagers.heartbeat-interval-ms'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.nodes.exclude-path'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.nodes.exclude-path'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.nodes.include-path'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.nodes.include-path'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.recovery.enabled'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.resource-tracker.address'] = "EVBYMINSD1F12T1.minsk.epam.com:8031" #or port 8025
default['hadoop']['yarn_site']['yarn.resourcemanager.resource-tracker.client.thread-count'] = '50'
default['hadoop']['yarn_site']['yarn.resourcemanager.scheduler.address'] = "EVBYMINSD1F12T1.minsk.epam.com:8030"
default['hadoop']['yarn_site']['yarn.resourcemanager.scheduler.class'] = "org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler"
default['hadoop']['yarn_site']['yarn.resourcemanager.scheduler.class'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.scheduler.client.thread-count'] = '50'
default['hadoop']['yarn_site']['yarn.resourcemanager.scheduler.monitor.enable'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.scheduler.monitor.policies'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.state-store.max-completed-applications'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.store.class'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.webapp.address'] = "EVBYMINSD1F12T1.minsk.epam.com:8088"
default['hadoop']['yarn_site']['yarn.resourcemanager.webapp.https.address'] = "EVBYMINSD1F12T1.minsk.epam.com:8090"
default['hadoop']['yarn_site']['yarn.resourcemanager.zk-acl'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.zk-address'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.zk-num-retries'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.zk-retry-interval-ms'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.zk-state-store.parent-path'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.zk-state-store.root-node.acl'] = nil
default['hadoop']['yarn_site']['yarn.resourcemanager.zk-timeout-ms'] = nil
default['hadoop']['yarn_site']['yarn.scheduler.fair.assignmultiple'] = false
default['hadoop']['yarn_site']['yarn.scheduler.fair.preemption'] = false
default['hadoop']['yarn_site']['yarn.scheduler.fair.sizebasedweight'] = false
default['hadoop']['yarn_site']['yarn.scheduler.fair.user-as-default-queue'] = true
default['hadoop']['yarn_site']['yarn.scheduler.increment-allocation-mb'] = '512'
default['hadoop']['yarn_site']['yarn.scheduler.maximum-allocation-mb'] = '4096'
default['hadoop']['yarn_site']['yarn.scheduler.maximum-allocation-vcores'] = '4'
default['hadoop']['yarn_site']['yarn.scheduler.minimum-allocation-mb'] = '1024'


# -> Configurations for NodeManager:

#default['hadoop']['yarn_site']['yarn.nodemanager.local-dirs'] = "/hadoop/mapred/yarn/local"
#default['hadoop']['yarn_site']['yarn.nodemanager.log-dirs'] = "/hadoop/mapred/yarn/log"
default['hadoop']['yarn_site']['yarn.nodemanager.address'] = "0.0.0.0:45454"
default['hadoop']['yarn_site']['yarn.nodemanager.admin-env'] = 'MALLOC_ARENA_MAX=$MALLOC_ARENA_MAX'
default['hadoop']['yarn_site']['yarn.nodemanager.aux-services'] = "mapreduce_shuffle"
default['hadoop']['yarn_site']['yarn.nodemanager.aux-services.mapreduce_shuffle.class'] = "org.apache.hadoop.mapred.ShuffleHandler"
default['hadoop']['yarn_site']['yarn.nodemanager.container-executor.class'] = "org.apache.hadoop.yarn.server.nodemanager.DefaultContainerExecutor"
default['hadoop']['yarn_site']['yarn.nodemanager.container-monitor.interval-ms'] = '3000'
default['hadoop']['yarn_site']['yarn.nodemanager.delete.debug-delay-sec'] = '0'
default['hadoop']['yarn_site']['yarn.nodemanager.disk-health-checker.min-healthy-disks'] = '0.25'
default['hadoop']['yarn_site']['yarn.nodemanager.health-checker.interval-ms'] = '135000'
default['hadoop']['yarn_site']['yarn.nodemanager.linux-container-executor.group'] = "hadoop"
default['hadoop']['yarn_site']['yarn.nodemanager.log-aggregation.compression-type'] = "gz"
default['hadoop']['yarn_site']['yarn.nodemanager.log.retain-seconds'] = '604800'
default['hadoop']['yarn_site']['yarn.nodemanager.remote-app-log-dir'] = "/app-logs"
default['hadoop']['yarn_site']['yarn.nodemanager.remote-app-log-dir-suffix'] = "logs"
default['hadoop']['yarn_site']['yarn.nodemanager.resource.memory-mb'] = '4096'
default['hadoop']['yarn_site']['yarn.nodemanager.vmem-check-enabled'] = false
default['hadoop']['yarn_site']['yarn.nodemanager.vmem-pmem-ratio'] = '2.1'


# -> Configurations for Health Checks of NodeManagers:
default['hadoop']['yarn_site']['yarn.nodemanager.health-checker.script.path'] = nil
default['hadoop']['yarn_site']['yarn.nodemanager.health-checker.script.opts'] = nil
default['hadoop']['yarn_site']['yarn.nodemanager.health-checker.script.interval-ms'] = nil
default['hadoop']['yarn_site']['yarn.nodemanager.health-checker.script.timeout-ms'] = '60000'


# -> Configurations for History Server 
default['hadoop']['yarn_site']['yarn.log-aggregation.retain-seconds'] = '2592000'
default['hadoop']['yarn_site']['yarn.log-aggregation.retain-check-interval-seconds'] = nil




###################################################################################################################################################################################################################################
# mapred-site.xml settings
###################################################################################################################################################################################################################################

# -> Configurations for MapReduce Applications:
default['hadoop']['mapred_site']['mapreduce.admin.map.child.java.opts'] = "-Djava.net.preferIPv4Stack=true -Dhadoop.metrics.log.level=WARN"
default['hadoop']['mapred_site']['mapreduce.admin.reduce.child.java.opts'] = "-Djava.net.preferIPv4Stack=true -Dhadoop.metrics.log.level=WARN"
default['hadoop']['mapred_site']['mapreduce.am.max-attempts'] = '2'
default['hadoop']['mapred_site']['mapreduce.cluster.administrators'] = "hadoop"
default['hadoop']['mapred_site']['mapreduce.framework.name'] = "yarn"
default['hadoop']['mapred_site']['mapreduce.job.reduce.slowstart.completedmaps'] = '1.0'
default['hadoop']['mapred_site']['mapreduce.map.java.opts'] = "-Djava.net.preferIPv4Stack=true -Xmx825955249" #-Xmx410m
default['hadoop']['mapred_site']['mapreduce.map.memory.mb'] = '512'
default['hadoop']['mapred_site']['mapreduce.reduce.input.buffer.percent'] = '0.0'
default['hadoop']['mapred_site']['mapreduce.reduce.java.opts'] = "-Djava.net.preferIPv4Stack=true -Xmx825955249"
default['hadoop']['mapred_site']['mapreduce.reduce.memory.mb'] = '1024'
default['hadoop']['mapred_site']['mapreduce.reduce.shuffle.parallelcopies'] = '30'
default['hadoop']['mapred_site']['mapreduce.shuffle.port'] = '13562'
default['hadoop']['mapred_site']['mapreduce.task.io.sort.factor'] = '100'
default['hadoop']['mapred_site']['mapreduce.task.io.sort.mb'] = '256' #205)
default['hadoop']['mapred_site']['yarn.app.mapreduce.am.admin-command-opts'] = "-Djava.net.preferIPv4Stack=true -Dhadoop.metrics.log.level=WARN"
default['hadoop']['mapred_site']['yarn.app.mapreduce.am.log.level'] = "INFO"

# -> Configurations for MapReduce JobHistory Server:
default['hadoop']['mapred_site']['mapreduce.client.submit.file.replication'] = '2'
default['hadoop']['mapred_site']['mapreduce.job.counters.max'] = '120'
default['hadoop']['mapred_site']['mapreduce.job.reduce.slowstart.completedmaps'] = '1.0'
default['hadoop']['mapred_site']['mapreduce.job.reduces'] = '7'
default['hadoop']['mapred_site']['mapreduce.job.split.metainfo.maxsize'] = '10000000'
default['hadoop']['mapred_site']['mapreduce.job.ubertask.enabled'] = false
default['hadoop']['mapred_site']['mapreduce.jobhistory.address'] = "#{node['fqdn']}:10020"
default['hadoop']['mapred_site']['mapreduce.jobhistory.done-dir'] = "/mr-history/done"
default['hadoop']['mapred_site']['mapreduce.jobhistory.intermediate-done-dir'] = "/mr-history/tmp"
default['hadoop']['mapred_site']['mapreduce.jobhistory.webapp.address'] = "#{node['fqdn']}:19888"
default['hadoop']['mapred_site']['mapreduce.map.cpu.vcores'] = '1'
default['hadoop']['mapred_site']['mapreduce.map.log.level'] = "INFO"
default['hadoop']['mapred_site']['mapreduce.map.output.compress'] = false
default['hadoop']['mapred_site']['mapreduce.map.output.compress.codec'] = "org.apache.hadoop.io.compress.SnappyCodec"
default['hadoop']['mapred_site']['mapreduce.map.sort.spill.percent'] = '0.7'
default['hadoop']['mapred_site']['mapreduce.map.speculative'] = false
default['hadoop']['mapred_site']['mapreduce.output.fileoutputformat.compress'] = false
default['hadoop']['mapred_site']['mapreduce.output.fileoutputformat.compress.codec'] = "org.apache.hadoop.io.compress.DefaultCodec"
default['hadoop']['mapred_site']['mapreduce.output.fileoutputformat.compress.type'] = "BLOCK"
default['hadoop']['mapred_site']['mapreduce.reduce.cpu.vcores'] = '1'
default['hadoop']['mapred_site']['mapreduce.reduce.log.level'] = "INFO"
default['hadoop']['mapred_site']['mapreduce.reduce.memory.mb'] = '1024'
default['hadoop']['mapred_site']['mapreduce.reduce.shuffle.input.buffer.percent'] = '0.7' 
default['hadoop']['mapred_site']['mapreduce.reduce.shuffle.merge.percent'] = '0.66'
default['hadoop']['mapred_site']['mapreduce.reduce.speculative'] = false
default['hadoop']['mapred_site']['mapreduce.task.timeout'] = '300000'
default['hadoop']['mapred_site']['yarn.app.mapreduce.am.command-opts'] = "-Djava.net.preferIPv4Stack=true -Xmx825955249" #-Xmx819m
default['hadoop']['mapred_site']['yarn.app.mapreduce.am.resource.cpu-vcores'] = '1'
default['hadoop']['mapred_site']['yarn.app.mapreduce.am.resource.mb'] = '1024'
default['hadoop']['mapred_site']['yarn.app.mapreduce.am.staging-dir'] = "/user"
default['hadoop']['mapred_site']['zlib.compress.level'] = "DEFAULT_COMPRESSION"
default['hadoop']['mapred_site']['mapreduce.application.classpath'] = "$HADOOP_MAPRED_HOME/*,$HADOOP_MAPRED_HOME/lib/*,$MR2_CLASSPATH"
#default['hadoop']['yarn_site']['mapreduce.application.classpath'] = "$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/*,$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/lib/*"
#default['hadoop']['mapred_site']['mapreduce.admin.user.env'] = "LD_LIBRARY_PATH=$HADOOP_COMMON_HOME/lib/native:$JAVA_LIBRARY_PATH"
#default['hadoop']['yarn_site']['mapreduce.admin.user.env'] = "LD_LIBRARY_PATH=/usr/lib/hadoop/lib/native:/usr/lib/hadoop/lib/native/`$JAVA_HOME/bin/java -d32 -version &amp;&gt; /dev/null;if [ $? -eq 0 ]; then echo Linux-i386-32; else echo Linux-amd64-64;fi`"
default['hadoop']['mapred_site']['mapreduce.shuffle.max.connections'] = '80'


###################################################################################################################################################################################################################################
# log4j.properties settings
###################################################################################################################################################################################################################################

# Define some default values that can be overridden by system properties
default['hadoop']['log4j']['hadoop.root.logger'] = "INFO,console"
default['hadoop']['log4j']['hadoop.log.dir'] = "/var/log/hadoop-hdfs"
default['hadoop']['log4j']['hadoop.log.file'] = "hadoop.log"

# Define the root logger to the system property "hadoop.root.logger".
default['hadoop']['log4j']['log4j.rootLogger'] = "${hadoop.root.logger}, EventCounter"

# Logging Threshold
default['hadoop']['log4j']['log4j.threshold'] = "ALL"

# Daily Rolling File Appender
default['hadoop']['log4j']['log4j.appender.DRFA'] = "org.apache.log4j.DailyRollingFileAppender"
default['hadoop']['log4j']['log4j.appender.DRFA.File'] = "${hadoop.log.dir}/${hadoop.log.file}"

# Rollver at midnight
default['hadoop']['log4j']['log4j.appender.DRFA.DatePattern'] = ".yyyy-MM-dd"
default['hadoop']['log4j']['log4j.appender.DRFA.layout'] = "org.apache.log4j.PatternLayout"
default['hadoop']['log4j']['log4j.appender.DRFA.layout.ConversionPattern'] = "%d{ISO8601} %p %c: %m%n"

# console
# Add "console" to rootlogger above if you want to use this 
default['hadoop']['log4j']['log4j.appender.console'] = "org.apache.log4j.ConsoleAppender"
default['hadoop']['log4j']['log4j.appender.console.target'] = "System.err"
default['hadoop']['log4j']['log4j.appender.console.layout'] = "org.apache.log4j.PatternLayout"
default['hadoop']['log4j']['log4j.appender.console.layout.ConversionPattern'] = "%d{yy/MM/dd HH:mm:ss} %p %c{2}: %m%n"

# TaskLog Appender
# Default values
default['hadoop']['log4j']['hadoop.tasklog.taskid'] = "null"
default['hadoop']['log4j']['hadoop.tasklog.iscleanup'] = false
default['hadoop']['log4j']['hadoop.tasklog.noKeepSplits'] = '4'
default['hadoop']['log4j']['hadoop.tasklog.totalLogFileSize'] = '100'
default['hadoop']['log4j']['hadoop.tasklog.purgeLogSplits'] = true
default['hadoop']['log4j']['hadoop.tasklog.logsRetainHours'] = '12'
default['hadoop']['log4j']['log4j.appender.TLA'] = "org.apache.hadoop.mapred.TaskLogAppender"
default['hadoop']['log4j']['log4j.appender.TLA.taskId'] = "${hadoop.tasklog.taskid}"
default['hadoop']['log4j']['log4j.appender.TLA.isCleanup'] = "${hadoop.tasklog.iscleanup}"
default['hadoop']['log4j']['log4j.appender.TLA.totalLogFileSize'] = "${hadoop.tasklog.totalLogFileSize}"
default['hadoop']['log4j']['log4j.appender.TLA.layout'] = "org.apache.log4j.PatternLayout"
default['hadoop']['log4j']['log4j.appender.TLA.layout.ConversionPattern'] = "%d{ISO8601} %p %c: %m%n"

#Security audit appender
default['hadoop']['log4j']['hadoop.security.logger'] = "INFO,console"
default['hadoop']['log4j']['hadoop.security.log.maxfilesize'] = "256MB"
default['hadoop']['log4j']['hadoop.security.log.maxbackupindex'] = '20'
default['hadoop']['log4j']['log4j.category.SecurityLogger'] = "${hadoop.security.logger}"
default['hadoop']['log4j']['hadoop.security.log.file'] = "SecurityAuth.audit"
default['hadoop']['log4j']['log4j.appender.DRFAS'] = "org.apache.log4j.DailyRollingFileAppender"
default['hadoop']['log4j']['log4j.appender.DRFAS.File'] = "${hadoop.log.dir}/${hadoop.security.log.file}"
default['hadoop']['log4j']['log4j.appender.DRFAS.layout'] = "org.apache.log4j.PatternLayout"
default['hadoop']['log4j']['log4j.appender.DRFAS.layout.ConversionPattern'] = "%d{ISO8601} %p %c: %m%n"
default['hadoop']['log4j']['log4j.appender.DRFAS.DatePattern'] = ".yyyy-MM-dd"
default['hadoop']['log4j']['log4j.appender.RFAS'] = "org.apache.log4j.RollingFileAppender"
default['hadoop']['log4j']['log4j.appender.RFAS.File'] = "${hadoop.log.dir}/${hadoop.security.log.file}"
default['hadoop']['log4j']['log4j.appender.RFAS.layout'] = "org.apache.log4j.PatternLayout"
default['hadoop']['log4j']['log4j.appender.RFAS.layout.ConversionPattern'] = "%d{ISO8601} %p %c: %m%n"
default['hadoop']['log4j']['log4j.appender.RFAS.MaxFileSize'] = "${hadoop.security.log.maxfilesize}"
default['hadoop']['log4j']['log4j.appender.RFAS.MaxBackupIndex'] = "${hadoop.security.log.maxbackupindex}"

# hdfs audit logging
default['hadoop']['log4j']['hdfs.audit.logger'] = "INFO,console"
default['hadoop']['log4j']['log4j.logger.org.apache.hadoop.hdfs.server.namenode.FSNamesystem.audit'] = "${hdfs.audit.logger}"
default['hadoop']['log4j']['log4j.additivity.org.apache.hadoop.hdfs.server.namenode.FSNamesystem.audit'] = false
default['hadoop']['log4j']['log4j.appender.DRFAAUDIT'] = "org.apache.log4j.DailyRollingFileAppender"
default['hadoop']['log4j']['log4j.appender.DRFAAUDIT.File'] = "${hadoop.log.dir}/hdfs-audit.log"
default['hadoop']['log4j']['log4j.appender.DRFAAUDIT.layout'] = "org.apache.log4j.PatternLayout"
default['hadoop']['log4j']['log4j.appender.DRFAAUDIT.layout.ConversionPattern'] = "%d{ISO8601} %p %c{2}: %m%n"
default['hadoop']['log4j']['log4j.appender.DRFAAUDIT.DatePattern'] = ".yyyy-MM-dd"

# mapred audit logging
default['hadoop']['log4j']['mapred.audit.logger'] = "INFO,console"
default['hadoop']['log4j']['log4j.logger.org.apache.hadoop.mapred.AuditLogger'] = "${mapred.audit.logger}"
default['hadoop']['log4j']['log4j.additivity.org.apache.hadoop.mapred.AuditLogger'] = false
default['hadoop']['log4j']['log4j.appender.MRAUDIT'] = "org.apache.log4j.DailyRollingFileAppender"
default['hadoop']['log4j']['log4j.appender.MRAUDIT.File'] = "${hadoop.log.dir}/mapred-audit.log"
default['hadoop']['log4j']['log4j.appender.MRAUDIT.layout'] = "org.apache.log4j.PatternLayout"
default['hadoop']['log4j']['log4j.appender.MRAUDIT.layout.ConversionPattern'] = "%d{ISO8601} %p %c{2}: %m%n"
default['hadoop']['log4j']['log4j.appender.MRAUDIT.DatePattern'] = ".yyyy-MM-dd"

# Rolling File Appender
default['hadoop']['log4j']['log4j.appender.RFA'] = "org.apache.log4j.RollingFileAppender"
default['hadoop']['log4j']['log4j.appender.RFA.File'] = "${hadoop.log.dir}/${hadoop.log.file}"
default['hadoop']['log4j']['log4j.appender.RFA.MaxFileSize'] = "256MB"
default['hadoop']['log4j']['log4j.appender.RFA.MaxBackupIndex'] = '10'
default['hadoop']['log4j']['log4j.appender.RFA.layout'] = "org.apache.log4j.PatternLayout"
default['hadoop']['log4j']['log4j.appender.RFA.layout.ConversionPattern'] = "%d{ISO8601} %-5p %c{2} - %m%n"
default['hadoop']['log4j']['log4j.appender.RFA.layout.ConversionPattern'] = "%d{ISO8601} %-5p %c{2} (%F:%M(%L)) - %m%n"

# Custom Logging levels
default['hadoop']['log4j']['hadoop.metrics.log.level'] = "INFO"
default['hadoop']['log4j']['log4j.logger.org.apache.hadoop.metrics2'] = "${hadoop.metrics.log.level}"
default['hadoop']['log4j']['log4j.logger.org.jets3t.service.impl.rest.httpclient.RestS3Service'] = "ERROR"
default['hadoop']['log4j']['log4j.appender.NullAppender'] = "org.apache.log4j.varia.NullAppender"
default['hadoop']['log4j']['log4j.appender.EventCounter'] = "org.apache.hadoop.log.metrics.EventCounter"

###################################################################################################################################################################################################################################
# hadoop-metrics.xml settings
###################################################################################################################################################################################################################################

default['hadoop']['hadoop_metrics']['mapred.class'] = "org.apache.hadoop.metrics.spi.NullContext"
default['hadoop']['hadoop_metrics']['rpc.class'] = "org.apache.hadoop.metrics.spi.NullContext"
default['hadoop']['hadoop_metrics']['ugi.class'] = "org.apache.hadoop.metrics.spi.NullContext"


###################################################################################################################################################################################################################################
# hadoop-policy.xml settings
###################################################################################################################################################################################################################################

default['hadoop']['hadoop_policy']['security.client.protocol.acl'] = "*"
default['hadoop']['hadoop_policy']['security.client.datanode.protocol.acl'] = "*"
default['hadoop']['hadoop_policy']['security.datanode.protocol.acl'] = "*"
default['hadoop']['hadoop_policy']['security.inter.datanode.protocol.acl'] = "*"
default['hadoop']['hadoop_policy']['security.namenode.protocol.acl'] = "*"
default['hadoop']['hadoop_policy']['security.admin.operations.protocol.acl'] = "*"
default['hadoop']['hadoop_policy']['security.refresh.usertogroups.mappings.protocol.acl'] = "*"
default['hadoop']['hadoop_policy']['security.refresh.policy.protocol.acl'] = "*"
default['hadoop']['hadoop_policy']['security.ha.service.protocol.acl'] = "*"
default['hadoop']['hadoop_policy']['security.zkfc.protocol.acl'] = "*"
default['hadoop']['hadoop_policy']['security.qjournal.service.protocol.acl'] = "*"
default['hadoop']['hadoop_policy']['security.mrhs.client.protocol.acl'] = "*"
default['hadoop']['hadoop_policy']['security.resourcetracker.protocol.acl'] = "*"
default['hadoop']['hadoop_policy']['security.resourcemanager-administration.protocol.acl'] = "*"
default['hadoop']['hadoop_policy']['security.applicationclient.protocol.acl'] = "*"
default['hadoop']['hadoop_policy']['security.applicationmaster.protocol.acl'] = "*"
default['hadoop']['hadoop_policy']['security.containermanagement.protocol.acl'] = "*"
default['hadoop']['hadoop_policy']['security.resourcelocalizer.protocol.acl'] = "*"
default['hadoop']['hadoop_policy']['security.job.task.protocol.acl'] = "*"
default['hadoop']['hadoop_policy']['security.job.client.protocol.acl'] = "*"

###################################################################################################################################################################################################################################
# capacity-scheduler.xml settings
###################################################################################################################################################################################################################################

default['hadoop']['capacity_scheduler']['yarn.scheduler.capacity.root.default.state'] = "RUNNING"
default['hadoop']['capacity_scheduler']['yarn.scheduler.capacity.root.default.capacity'] = '100'
default['hadoop']['capacity_scheduler']['yarn.scheduler.capacity.root.default.acl_administer_jobs'] = "*"
default['hadoop']['capacity_scheduler']['yarn.scheduler.capacity.maximum-am-resource-percent'] = '0.2'
default['hadoop']['capacity_scheduler']['yarn.scheduler.capacity.root.unfunded.capacity'] = '50'
default['hadoop']['capacity_scheduler']['yarn.scheduler.capacity.root.default.acl_submit_jobs'] = "*"
default['hadoop']['capacity_scheduler']['yarn.scheduler.capacity.root.acl_administer_queues'] = "*"
default['hadoop']['capacity_scheduler']['yarn.scheduler.capacity.maximum-applications'] = '10000'
default['hadoop']['capacity_scheduler']['yarn.scheduler.capacity.node-locality-delay'] = '40'
default['hadoop']['capacity_scheduler']['yarn.scheduler.capacity.root.default.maximum-capacity'] = '100'
default['hadoop']['capacity_scheduler']['yarn.scheduler.capacity.root.capacity'] = '100'
default['hadoop']['capacity_scheduler']['yarn.scheduler.capacity.root.default.user-limit-factor'] = '1'
default['hadoop']['capacity_scheduler']['yarn.scheduler.capacity.root.queues'] = "default"
