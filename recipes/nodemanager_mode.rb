chef_gem "chef-rewind"
require 'chef/rewind'

if ( File.exists?("/run/hadoop-yarn/yarn-yarn-nodemanager.pid") or node['hadoop_services']['already_nodemanager'] ) then

    Chef::Log.warn ("!!! U already have NodeManager running !!!")

else 

    include_recipe "java_wrapper"

    include_recipe "hadoop::hadoop_yarn_nodemanager"

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