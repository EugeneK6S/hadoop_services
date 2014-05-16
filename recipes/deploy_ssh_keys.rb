require 'net/ssh'

# ::Chef::Recipe.send(:include, HadoopStrings)

class Chef::Recipe
    include HadoopStrings
end

Chef::Log.info("The status of ssh_key_pair is: #{node['hadoop_services']['ssh']['status']}")

# if ::File.exists?("#{node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.dir']}")
# 	Chef::Log.info("Directory #{node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.dir']}already exists, do nothing.")
# else
#     Dir::mkdir("#{node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.dir']}")
# end


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


# if ::File.exists?("#{node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.authorized-key-files']}")
#                 Chef::Log.info("File authorized_keys already exists, do nothing.")
# else
#                 file = File.open("#{node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.authorized-key-files']}", "w")
#                 file.write("")
#                 file.close
# end

Chef::Log.info("Searching servers in your project...")
servers_pk = Array.new
search(:node, "project:#{node['project']}") do |n|
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

Chef::Log.info("Authorized keys were updated")