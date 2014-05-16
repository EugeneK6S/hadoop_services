chef_gem "chef-rewind"
require 'chef/rewind'

if ( File.exists?("/jmode") or node['hadoop_services']['already_journalnode'] ) then

    Chef::Log.warn ("!!! U already have JournalNode running !!!")

else 

    include_recipe "java_wrapper"

    include_recipe "hadoop::hadoop_hdfs_journalnode"

    rewind "service[hadoop-hdfs-journalnode]" do
      supports :status => true, :start => true, :stop => true, :restart => true
      action [:enable, :start]
    end

    ruby_block "report_journalnode_status" do
        block do
        node.set['hadoop_services']['already_journalnode'] = true
        end
        action :nothing
    end    

end