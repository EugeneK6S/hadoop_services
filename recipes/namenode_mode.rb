#
# Cookbook Name:: hadoop_services
# Recipe:: namenode_mode
#
# Copyright 2014, EPAM Systems and Ievgen_Kabanets brain :)
#
# All rights reserved - Do Not Redistribute
#


# if node['hadoop']['hdfs_site'].has_key? 'dfs+namenode+http-address+mycluster+nn1' 
# 	node.set['hadoop']['hdfs_site']['dfs.namenode.http-address.mycluster.nn1'] = node['hadoop']['hdfs_site']['dfs+namenode+http-address+mycluster+nn1']
# end

tmp = node['hadoop']['hdfs_site']['dfs.namenode.shared.edits.dir']
dfs_shared_edit = tmp[7..-1]
Chef::Log.info("#{dfs_shared_edit}")


chef_gem "chef-rewind"
require 'chef/rewind'
require 'net/ssh'
require 'resolv'

## Setting attributes needed for config generation based on roles

act_nn_array = Array.new
search(:node, "role:hadoop-namenode AND hadoop_services_is_active_nn:true AND project:#{node['project']}").each do |n|
	act_nn_array << n['fqdn']
	act_nn_array.each do |nn1|
		nn1_edit = "hdfs:"
		node.set['hadoop']['hdfs_site']['dfs.namenode.rpc-address.mycluster.nn1'] = nn1 + ":8020"
		node.set['hadoop']['hdfs_site']['dfs.namenode.http-address.mycluster.nn1'] = nn1 + ":50070"
		node.set['hadoop']['core_site']['fs.defaultFS'] = "hdfs://" + nn1 + ":8020"
		node.set['hadoop_services']['ha.zookeeper.quorum.part1'] = nn1
		Chef::Log.info("#{node['hadoop_services']['ha.zookeeper.quorum.part1']}")
	end
end

stndby_nn_array = Array.new
search(:node, "role:hadoop-namenode AND hadoop_services_is_standby_nn:true AND project:#{node['project']}").each do |n|
	stndby_nn_array << n['fqdn']
	stndby_nn_array.each do |nn2|
		node.set['hadoop']['hdfs_site']['dfs.namenode.rpc-address.mycluster.nn2'] = nn2 + ":8020"
		node.set['hadoop']['hdfs_site']['dfs.namenode.http-address.mycluster.nn2'] = nn2 + ":50070"
		node.set['hadoop_services']['ha.zookeeper.quorum.part2'] = nn2
		Chef::Log.info("#{node['hadoop_services']['ha.zookeeper.quorum.part2']}")
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
			
tmp_hosts = node['hadoop']['hdfs_site']['dfs.namenode.http-address.mycluster.nn1']
dns_name = tmp_hosts[0..-7]
ip_addr = Resolv.getaddress(dns_name.to_s)

ruby_block "add_to_hosts" do
	block do
		File.open('/etc/hosts', 'a') { |f| f.write("#{ip_addr} mycluster") }
	end
	not_if { File.open('/etc/hosts').lines.any?{|line| line.include?("#{ip_addr}")} }
end



##################################################################################################################
## Generate and deploy SSH private and public keys.
##################################################################################################################

if node['platform_family'] == 'rhel'

	yum_repository 'bigtop' do
	  description "BigTop Stable repo"
	  baseurl "http://bigtop.s3.amazonaws.com/releases/0.7.0/redhat/6/x86_64"
	  gpgkey 'http://archive.apache.org/dist/bigtop/KEYS'
	  action :create
	end

	yum_package "bigtop-utils" do
	  action :install
	end

end

if ( node['hadoop_services']['ssh']['status'] == "need_generate" ) 

	Chef::Log.info("The new key pair will be generated")
		
		ruby_block "preparing key-pair" do
			block do
				key = OpenSSL::PKey::RSA.new 2048
				type = key.ssh_type
				data = [ key.to_blob ].pack('m0')
				openssh_format = "#{type} #{data}"
				node.set['hadoop_services']['ssh']['private_key'] = key
				node.set['hadoop_services']['ssh']['public_key'] = openssh_format
				node.set['hadoop_services']['ssh']['status'] = "created"
				end
			action :create
		end
end

ruby_block "deploy id_rsa" do
    block do
        fname = "#{node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.private-key-files']}"  
        modfile = File.open(fname, "w")
        modfile.puts node['hadoop_services']['ssh']['private_key']
        modfile.close
    end
    only_if { node['hadoop_services']['ssh']['private_key'] != nil }               
end

ruby_block "deploy id_rsa.pub" do
    block do
        fname = "#{node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.private-key-files']}.pub"
        modfile = File.open(fname, "w")
        modfile.puts node['hadoop_services']['ssh']['public_key']
        modfile.close
    end
    only_if { node['hadoop_services']['ssh']['public_key'] != nil }
end


Chef::Log.info("Searching servers in your project...")
servers_pk = Array.new
search(:node, "project:#{node['project']} AND role:hadoop-namenode") do |n|
    if node['fqdn'] != n['fqdn'] then
        if n['hadoop_services']['ssh']['public_key'] != nil then
			##################################################################################################################
			## If keys of Active NameNode are already present - we can start 
			######################################################################################################

            Chef::Log.info(n['fqdn'])
            servers_pk << n['hadoop_services']['ssh']['public_key']
            fname = "#{node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.authorized-key-files']}"
			servers_pk.each do |m|
				strcont = m+"\n"
			    if File.open(fname).lines.any?{|line| line.include?(strcont)}
			        Chef::Log.info("Key already exists in authorized")
			    else
			        ruby_block "deploy authorized_keys" do
			            block do
			                modfile = File.open(fname, "a")
			                modfile.puts ""
			                modfile.puts m
			                modfile.close
			            end
			        end
					Chef::Log.info("Authorized keys were updated")
			    end
			end


			include_recipe "hadoop::default"

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

			# include_recipe "nfs::default"

			# if (File.directory?("#{dfs_shared_edit}") == false) then
			# 	directory "#{dfs_shared_edit}" do
			# 	  	mode "0755"
			# 	  	owner "hdfs"
			# 	  	group "hdfs"
			# 	  	action :create
			# 	  	recursive true
			# 	end
			# end

			# search(:node, "role:hadoop-nfs-share").each do |n|

			# 	mount "#{dfs_shared_edit}" do
			# 		device "#{n['ipaddress']}:#{node['hadoop_services']['nfs_dir']}"
			# 		fstype "nfs"
			# 		options "rw"
			# 		action [:mount, :enable]
			# 		only_if { ::File.exist?("#{dfs_shared_edit}") }
			# 	end

			# end


			##################################################################################################################
			## Check whether this is not already a NameNode
			##################################################################################################################
			if ( File.exists?("/tmp/hadoop-hdfs-namenode.pid") or node['hadoop_services']['already_namenode'] ) then

				Chef::Log.warn ("!!! U already have NameNode running !!!")

				if ( node['hadoop_services'].has_key? 'is_active_nn' and node['hadoop_services']['is_active_nn'] == "true" ) then
					Chef::Log.warn ("!!! No need to sync Active NameNode  !!!")
				else 
					execute "hdfs-sync-standby" do
					  	command <<-EOF
					  	chown -R hdfs:hdfs #{node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.dir']}
						scp -o "StrictHostKeyChecking no" -i /var/lib/hadoop-hdfs/.ssh/id_rsa hdfs@#{ip_active_nn}:#{dfs_shared_edit}/current/edits* #{dfs_shared_edit}/current/
						scp -o "StrictHostKeyChecking no" -i /var/lib/hadoop-hdfs/.ssh/id_rsa hdfs@#{ip_active_nn}:#{dfs_shared_edit}/current/VERSION #{dfs_shared_edit}/current/
					  	EOF
					  	group "root"
					  	user "root"
					  	action :run
					end
				end

			
			##################################################################################################################
			## Call to Hadoop community cookbooks, creating config files and installing hadoop soft 
			##################################################################################################################
			else 	

				include_recipe "java_wrapper"
				include_recipe "hadoop::hadoop_hdfs_namenode"
				include_recipe "hadoop::zookeeper_server"
				include_recipe "hadoop::hadoop_hdfs_zkfc"



				ruby_block "fix_yarn_env" do
				    block do
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

				cookbook_file "commons-logging.properties" do
			  		path "#{node['hadoop']['hadoop_env']['hadoop_conf_dir']}/commons-logging.properties"
					mode "0755"
				    owner "hdfs"
				    group "hdfs"
			  		action :create_if_missing
				end


				# ruby_block "fix_hadoop_env" do
				#     block do
				# 	File.open('/etc/hadoop/conf.chef/hadoop-env.sh', 'a')  { |f|
				# 		  f << "JAVA_JDBC_LIBS=\"\"\n"
				# 		  f << "for jarFile in `ls /usr/share/java/*mysql* 2>/dev/null`\n"
				# 		  f << "do\n"
				# 		  f << "JAVA_JDBC_LIBS=${JAVA_JDBC_LIBS}:$jarFile\n"
				# 		  f << "done\n"
				# 		  f << "for jarFile in `ls /usr/share/java/*ojdbc* 2>/dev/null`\n"
				# 		  f << "do\n"
				# 		  f << "JAVA_JDBC_LIBS=${JAVA_JDBC_LIBS}:$jarFile\n"
				# 		  f << "done\n"
				# 		  f << "export JAVA_JDBC_LIBS\n"
				# 		  f.close
				# 	  }
				# 	end
				# end

				
				Chef::Log.info("Reloading hadoop-hdfs-namenode service...")

				rewind "service[hadoop-hdfs-namenode]" do
				  action :reload
				end

				Chef::Log.info("Reloaded hadoop-hdfs-namenode service successfully")

			##################################################################################################################
			## Creating needed directories for Hadoop modules 
			##################################################################################################################

				# directory "#{dfs_shared_edit}" do
				#   mode "0755"
				#   owner "hdfs"
				#   group "hdfs"
				#   action :create
				#   recursive true
				# end

				directory "#{node['zookeeper']['zoocfg']['dataLogDir']}" do
				  mode "0755"
				  owner "zookeeper"
				  group "zookeeper"
				  action :create
				  recursive true
				end

				directory "#{node['hadoop']['hadoop_env']['hadoop_mapred_log_dir']}" do
				  mode "0755"
				  owner "mapred"
				  group "mapred"
				  action :create
				  recursive true
				end

				directory "#{node['hadoop']['hadoop_env']['hadoop_pid_dir']}" do
				  mode "0755"
				  owner "hdfs"
				  group "hdfs"
				  action :create
				  recursive true
				end

				directory "#{node['hadoop']['hadoop_env']['hadoop_mapred_pid_dir']}" do
				  mode "0755"
				  owner "mapred"
				  group "mapred"
				  action :create
				  recursive true
				end

				execute "hdfs-chown-dirs" do
					command <<-EOF 
					chown -R hdfs:hdfs #{node['hadoop']['hadoop_env']['hadoop_prefix']}-* 
					chown -R hdfs:hdfs #{node['hadoop']['conf_dir']} 
					chown -R hdfs:hdfs #{dfs_shared_edit}
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
				


			## Check if node is ACTIVE or STANDBY

				

			##################################################################################################################
			##  ACTIVE Namenode deployment
			##################################################################################################################

				if (node['hadoop_services'].has_key? 'is_active_nn' and node['hadoop_services']['is_active_nn'] == "true")

					execute "hdfs-chown-dirs" do
						command <<-EOF 
							chown -R hdfs:hdfs #{node['hadoop']['hadoop_env']['hadoop_prefix']}-* 
							chown -R hdfs:hdfs #{node['hadoop']['conf_dir']} 
							chown -R hdfs:hdfs #{dfs_shared_edit}
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

					rewind "execute[hdfs-namenode-format]" do
						#sudo su - hdfs -c "yes Y | hdfs namenode -format" >> format_file 2>&1
						command <<-EOF
						mkdir -p #{dfs_shared_edit}
						chown -R hdfs:hdfs #{dfs_shared_edit}
					    sudo su - hdfs -c "yes Y | /usr/lib/hadoop/bin/hadoop namenode -format" >> /var/log/format_file 2>&1
					    EOF
					    #creates "#{node['hadoop_services']['hadoop_config_prefix']}/namenode.formatted"
						group "root"
					  	user "root"
					    action :run
					    notifies :run, 'execute[hdfs-chown-dirs]', :immediately
					end

					execute "hdfs-chown-dirs" do
						command <<-EOF 
							chown -R hdfs:hdfs #{node['hadoop']['hadoop_env']['hadoop_prefix']}-* 
							chown -R hdfs:hdfs #{node['hadoop']['conf_dir']} 
							chown -R hdfs:hdfs #{dfs_shared_edit}
							chown -R hdfs:hdfs /tmp/hadoop-*
							chown -R hdfs:hdfs #{node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.dir']}
					  		chown -R zookeeper:zookeeper #{node['zookeeper']['zoocfg']['dataLogDir']}
					  		chown -R hdfs:hdfs #{node['hadoop']['core_site']['hadoop.tmp.dir']}
					  		chown -R hdfs:hdfs #{node['hadoop']['hadoop_env']['hadoop_log_dir']}
					  		chown -R hdfs:hdfs #{node['hadoop']['hadoop_env']['hadoop_mapred_home']}
						EOF
						action :nothing
						group "root"
						user "root"
					end

					execute "zookeeper-server-start" do
					  	command <<-EOF
					 	/etc/init.d/zookeeper-server start
					  	EOF
					  	group "root"
					  	user "root"
					  	action :run
					  	notifies :run, 'execute[hdfs-chown-dirs]', :immediately
					end

					execute "zkfc-formatZK" do
					    command <<-EOF
					    sudo su - hdfs -c "yes Y | hdfs zkfc -formatZK"
					  	EOF
					  	group "root"
					  	user "root"
					  	action :run
					  	notifies :run, 'execute[hdfs-chown-dirs]', :immediately
					end

					execute "hdfs-namenode-start" do
					    command <<-EOF
						sudo su - hdfs -c "yes Y | #{node['hadoop']['hadoop_env']['hadoop_prefix']}/sbin/hadoop-daemon.sh --config /etc/hadoop/conf.chef/ --script hdfs start namenode"
						EOF
						group "root"
						user "root"
						action :run
						notifies :run, 'execute[hdfs-chown-dirs]', :immediately
					end

					
					execute "zkfc-start" do
						command <<-EOF
						sudo su - hdfs -c "yes Y | #{node['hadoop']['hadoop_env']['hadoop_prefix']}/sbin/hadoop-daemon.sh --config /etc/hadoop/conf.chef/ start zkfc"
						EOF
						group "root"
						user "root"
						action :run
						notifies :run, 'execute[hdfs-chown-dirs]', :immediately
						notifies :create, 'ruby_block[report_namenode_status]', :immediately
					end


					ruby_block "report_namenode_status" do
					    block do
							node.set['hadoop_services']['already_namenode'] = true
					    end
					    action :nothing
					end


					# rewind "service[hadoop-hdfs-zkfc]" do
					# 	action :start
					# end



			##################################################################################################################
			##  STANDBY Namenode deployment
			##################################################################################################################
				else 

					Chef::Log.info("Searching servers in your project...")
					servers_pk = Array.new
					search(:node, "project:#{node['project']} AND role:hadoop-namenode") do |n|
					    if node['fqdn'] != n['fqdn'] then
					            if n['hadoop_services']['ssh']['public_key'] != nil then
					                    Chef::Log.info(n['fqdn'])
					                    servers_pk << n['hadoop_services']['ssh']['public_key']

					            end
					    end
					end

					fname = "#{node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.authorized-key-files']}"
					servers_pk.each do |m|
						strcont = m+"\n"
						if File.open(fname).lines.any?{|line| line.include?(strcont)}
							Chef::Log.info("Key already exists in authorized")
						else
							ruby_block "deploy authorized_keys" do
							    block do
							        modfile = File.open(fname, "a")
							        modfile.puts ""
							        modfile.puts m
							        modfile.close
							    end
							end
						end
					end

					execute "hdfs-chown-dirs" do
						command <<-EOF 
							chown -R hdfs:hdfs #{node['hadoop']['hadoop_env']['hadoop_prefix']}-* 
							chown -R hdfs:hdfs #{node['hadoop']['conf_dir']} 
							chown -R hdfs:hdfs #{dfs_shared_edit}
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

					rewind "execute[hdfs-namenode-format]" do
						command <<-EOF
						mkdir -p #{dfs_shared_edit}
						chown -R hdfs:hdfs #{dfs_shared_edit}
					    sudo su - hdfs -c "yes Y | hdfs namenode -format"
					    EOF
					    #creates "#{node['hadoop_services']['hadoop_config_prefix']}/namenode.formatted"
					    action :run
					    group "root"
					  	user "root"
					    notifies :run, 'execute[hdfs-chown-dirs]', :immediately
					end

					execute "hdfs-chown-dirs" do
						command <<-EOF 
							chown -R hdfs:hdfs #{node['hadoop']['hadoop_env']['hadoop_prefix']}-* 
							chown -R hdfs:hdfs #{node['hadoop']['conf_dir']} 
							chown -R hdfs:hdfs #{dfs_shared_edit}
							chown -R hdfs:hdfs /tmp/hadoop-*
							chown -R hdfs:hdfs #{node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.dir']}
					  		chown -R zookeeper:zookeeper #{node['zookeeper']['zoocfg']['dataLogDir']}
					  		chown -R hdfs:hdfs #{node['hadoop']['core_site']['hadoop.tmp.dir']}
					  		chown -R hdfs:hdfs #{node['hadoop']['hadoop_env']['hadoop_log_dir']}
					  		chown -R hdfs:hdfs #{node['hadoop']['hadoop_env']['hadoop_mapred_home']}
						EOF
						action :nothing
						group "root"
						user "root"
					end


					# rewind "service[zookeeper-server]" do
					# 	action [:enable, :start]
					# 	notifies :run, 'execute[hdfs-chown-dirs]', :immediately
					# end

					execute "zookeeper-server-start" do
					  	command <<-EOF
					 	/etc/init.d/zookeeper-server start
					  	EOF
					  	group "root"
					  	user "root"
					  	action :run
					  	notifies :run, 'execute[hdfs-chown-dirs]', :immediately
					end

					tmp_ip_active_nn = node['hadoop']['hdfs_site']['dfs.namenode.http-address.mycluster.nn1']
					ip_active_nn = tmp_ip_active_nn[0..-7]

					execute "zkfc-formatZK" do
					    command <<-EOF
					    sudo su - hdfs -c "yes Y | hdfs zkfc -formatZK"
					  	EOF
					  	group "root"
					  	user "root"

						notifies :run, 'execute[fix_HDFS-3752_bootstrap_standby]', :immediately
					  	action :nothing
					end

					execute "fix_HDFS-3752_bootstrap_standby" do
					  	command <<-EOF
					  	chown -R hdfs:hdfs #{node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.dir']}
						scp -o "StrictHostKeyChecking no" -i /var/lib/hadoop-hdfs/.ssh/id_rsa hdfs@#{ip_active_nn}:#{dfs_shared_edit}/current/edits* #{dfs_shared_edit}/current/
						scp -o "StrictHostKeyChecking no" -i /var/lib/hadoop-hdfs/.ssh/id_rsa hdfs@#{ip_active_nn}:#{dfs_shared_edit}/current/VERSION #{dfs_shared_edit}/current/
						sudo su - hdfs -c "yes Y | hdfs namenode -bootstrapStandby"
					  	EOF
					  	group "root"
					  	user "root"
					  	action :run
					  	notifies :run, 'execute[hdfs-chown-dirs]', :immediately
						notifies :run, 'execute[hdfs-namenode-start]', :immediately					  	
					end

					# rewind "execute[hdfs-namenode-bootstrap-standby]" do
					# 	command "sudo yes Y | hdfs namenode -bootstrapStandby"
					# 	group "hdfs"
					#     user "hdfs"
					# 	action :run
					# end


					# execute "hdfs-namenode-initialize-sharededits" do
					#   command "hdfs namenode -initializeSharedEdits"
					#   action :run
					#   group "hdfs"
					#   user "hdfs"
					# end



					execute "hdfs-namenode-start" do
					    command <<-EOF
						sudo su - hdfs -c "yes Y | #{node['hadoop']['hadoop_env']['hadoop_prefix']}/sbin/hadoop-daemon.sh --config /etc/hadoop/conf.chef/ --script hdfs start namenode"
						EOF
						group "root"
						user "root"
						action :nothing
						notifies :run, 'execute[hdfs-chown-dirs]', :immediately
						notifies :run, 'execute[zkfc-start]', :immediately
					end

					execute "zkfc-start" do
						command <<-EOF
						ps aux
						sudo su - hdfs -c "yes Y | #{node['hadoop']['hadoop_env']['hadoop_prefix']}/sbin/hadoop-daemon.sh --config /etc/hadoop/conf.chef/ start zkfc"
						EOF
						group "root"
						user "root"
						action :run
						notifies :run, 'execute[hdfs-chown-dirs]', :immediately
						notifies :create, 'ruby_block[report_namenode_status]', :immediately			
					end

					# rewind "service[hadoop-hdfs-zkfc]" do
					# 	action :start
					# end

					ruby_block "report_namenode_status" do
					    block do
							node.set['hadoop_services']['already_namenode'] = true
					    end
					    action :nothing
					end
				end
			end
	    else 
	    	Chef::Log.info("I'm not ready yet")
	    end
    end
end
