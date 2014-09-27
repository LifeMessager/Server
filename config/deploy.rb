# capistrano/rbenv: https://github.com/capistrano/rbenv
# capistrano/bundler: https://github.com/capistrano/bundler
# capistrano-postgresql: https://github.com/bruno-/capistrano-postgresql
# capistrano-unicorn-nginx: https://github.com/bruno-/capistrano-unicorn-nginx
# capistrano-safe-deploy-to: https://github.com/bruno-/capistrano-safe-deploy-to

require 'pathname'

# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'lifemessager'
set :deploy_user, fetch(:application)
set :deploy_to, "/home/#{fetch(:deploy_user)}/#{fetch(:application)}" # Default is /var/www/my_app
set :configs, YAML.load_file(Pathname.new './config/cap_config.yml')

# setup repo details
# set :scm, :git # Default value for :scm is :git
set :repo_url, 'https://github.com/bolasblack/diary.git'

# setup rbenv.
set :rbenv_type, :user
set :rbenv_ruby, '2.1.1'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}

# setup nginx
set :nginx_server_name, 'lifemessager.com' # Default is server's IP address
set :nginx_pid, "/var/run/nginx.pid" # Default path is "/run/nginx.pid"
# set :nginx_location, # Default path is "/etc/nginx"
set :nginx_access_log_file, "/var/log/nginx/#{fetch(:application)}_access.log" # Default is shared_path.join('log/nginx.access.log')
set :nginx_error_log_file, "/var/log/nginx/#{fetch(:application)}_error.log" # Default is shared_path.join('log/nginx.error.log')

# setup unicorn
# set :unicorn_service, # Default is "unicorn_#{fetch(:application)}_#{fetch(:stage)}"
# set :unicorn_pid, # Default is shared_path.join("tmp/pids/unicorn.pid")
# set :unicorn_config, # Default is shared_path.join("config/unicorn.rb")
# set :unicorn_workers, # Default is 2

# setup postgresql
# set :pg_database, # Default is "#{fetch(:application)}_#{fetch(:stage)}"
# set :pg_user, # Default is whatever is set for `pg_database` option
# set :pg_password, ENV["PG_PASSWORD"] # Default generate a new random password each time create a new database

# setup whenever
set :whenever_identifier, ->{ "#{fetch :application}_#{fetch :stage}" }


# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# files we want symlinking to specific entries in shared
set :linked_files, %w{config/database.yml .env} # Default value for :linked_files is []

# dirs we want symlinking to shared
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system} # Default value for linked_dirs is []

# set :default_env, { path: "/opt/ruby/bin:$PATH" } Default value for default_env is {}

# how many old releases do we want to keep, not much
# set :keep_releases, 5 # Default value for keep_releases is 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
