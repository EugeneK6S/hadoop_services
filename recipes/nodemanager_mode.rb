chef_gem "chef-rewind"
require 'chef/rewind'
require 'resolv'

if ( File.exists?("/run/hadoop-yarn/yarn-yarn-nodemanager.pid") or node['hadoop_services']['already_nodemanager'] ) then

    Chef::Log.warn ("!!! U already have NodeManager running !!!")
else 

    include_recipe "java_wrapper"

    include_recipe "hadoop::hadoop_yarn_nodemanager"
           
    tmp_hosts = node['hadoop']['hdfs_site']['dfs.namenode.http-address.mycluster.nn1']
    dns_name = tmp_hosts[0..-7]
    id_addr = Resolv.getaddress(dns_name)

    ruby_block "add_to_hosts" do
        block do
            File.open('/etc/hosts', 'a') { |f| f.write("#{id_addr} mycluster") }
        end
        not_if { File.open('/etc/hosts').lines.any?{|line| line.include?("#{id_addr}")} }
    end


    execute "hdfs-chown-dirs" do
    command <<-EOF 
        chown -R hdfs:hdfs #{node['hadoop']['hadoop_env']['hadoop_prefix']}-* 
        chown -R hdfs:hdfs #{node['hadoop']['conf_dir']} 
        chown -R hdfs:hdfs /tmp/hadoop-*
        chown -R hdfs:hdfs #{node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.dir']}
        chown -R zookeeper:zookeeper #{node['zookeeper']['zoocfg']['dataLogDir']}
        chown -R hdfs:hdfs #{node['hadoop']['core_site']['hadoop.tmp.dir']}
        chown -R hdfs:hdfs #{node['hadoop']['hadoop_env']['hadoop_log_dir']}
        chown -R hdfs:hdfs #{node['hadoop']['hadoop_env']['hadoop_mapred_home']}
    EOF
    action :run
    group "root"
    user "root"
    end

    rewind "service[hadoop-yarn-nodemanager]" do
      supports :status => true, :start => true, :stop => true, :restart => true
      action [:enable, :start]
    end

    ruby_block "report_nodemanager_status" do
        block do
        node.set['hadoop_services']['already_nodemanager'] = true
        end
        action :nothing
    end    

end