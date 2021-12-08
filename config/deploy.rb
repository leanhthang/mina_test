require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)
require 'mina/rvm'    # for rvm support. (https://rvm.io)

set :application_name, 'mina_test'
set :repository, 'git@git.advn.vn:product/distribution.advn.git'

task :deploy_dev => :environment do
  set :rails_env, 'production'
  set :domain, 'localhost'
  set :branch, 'master'
  set :deploy_to, '/home/lat/mypj/deploy'

  set :user, 'ruby'          # Username in the server to SSH to.
  set :port, '7000'           # SSH port number.
end

task :local => :environment do
  set :rails_env, 'production'
  set :domain, 'localhost'
  set :branch, 'master'
  set :deploy_to, '/home/lat/mypj/deploy'

  set :user, 'lat'          # Username in the server to SSH to.
  set :port, '3000'           # SSH port number.

  # invoke :'rbenv:load'
end

task :local_environment do
  invoke :'rvm:use', 'ruby-2.7.2@default'
end

# Optional settings:
set :forward_agent, true     # SSH forward_agent.
set :shared_dirs, fetch(:shared_dirs, []).push('log', 'tmp/pids', 'tmp/sockets', 'public/uploads', 'storage')
set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml')

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # command %{rbenv install 2.7.2 --skip-existing}
  command %{rvm install ruby-2.7.2}
  command %{gem install bundler}
end

desc "Deploys the current version to the server."
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %{mkdir -p tmp/}
        command %{mkdir -p log/}
        command %{touch tmp/restart.txt}
      end
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end