set :application, "actionecho"
set :user, "actionecho"
set :runner, "#{user}"

set :scm, :git
set :repository,  "git://github.com/pfdemuizon/phoneinreport.git"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/#{user}/#{application}"

role :app, "slicehost.radicaldesigns.org"
role :web, "slicehost.radicaldesigns.org"
role :db,  "slicehost.radicaldesigns.org", :primary => true

set :branch, "master"
set :deploy_via, :remote_cache

after "deploy:update_code", "deploy:symlink_shared"

namespace :deploy do
  task :start, :roles => :app do
    #invoke_command "monit -g actionecho start all", :via => run_method
    invoke_command "mongrel_rails cluster::restart", :via => run_method
  end

  task :symlink_shared, :roles => :app, :except => {:no_symlink => true} do 
    invoke_command "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    invoke_command "ln -nfs #{shared_path}/config/mongrel_cluster.yml #{release_path}/config/mongrel_cluster.yml"
    invoke_command "ln -nfs #{shared_path}/config/amazon_s3.yml #{release_path}/config/amazon_s3.yml"
  end
end
