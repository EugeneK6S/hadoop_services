
case node['platform_family']
when 'debian'
        if (File.directory?("#{node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.dir']}") == false) then
                dir1 = directory node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.dir'] do
                        owner "user"
                        group "user"
                        mode 00700
                        action :nothing
                        recursive true
                end
                dir1.run_action(:create)
        end

        f1 = file node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.authorized-key-files'] do
                owner "user"
                group "user"
                mode 00600
                action :nothing
        end
        f1.run_action(:create_if_missing)

        f2 = file node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.private-key-files'] do 
                owner "user"
                group "user"
                mode 00600
                action :nothing
        end
        f2.run_action(:create_if_missing)

        f3 = file node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.public-key-files'] do
                owner "user"
                group "user"
                mode 00644
                action :nothing
        end
        f3.run_action(:create_if_missing)
        
when 'rhel'
        if (File.directory?("#{node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.dir']}") == false) then
                dir1 = directory node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.dir'] do
                        owner "root"
                        group "root"
                        mode 00700
                        action :nothing
                        recursive true
                end
                dir1.run_action(:create)
        end

        f1 = file node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.authorized-key-files'] do
                owner "root"
                group "root"
                mode 00600
                action :nothing
        end
        f1.run_action(:create_if_missing)

        f2 = file node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.private-key-files'] do 
                owner "root"
                group "root"
                mode 00600
                action :nothing
        end
        f2.run_action(:create_if_missing)

        f3 = file node['hadoop']['hdfs_site']['dfs.ha.fencing.ssh.public-key-files'] do
                owner "root"
                group "root"
                mode 00644
                action :nothing
        end
        f3.run_action(:create_if_missing)
end