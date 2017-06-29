# config valid only for current version of Capistrano
lock "3.8.2"

set :application, "exp.trb.to"
set :repo_url, "git@github.com:konung/exp.git"

# Instead of storing keys on the server. Make sure ssh-agent is up and running on the local machine.
set :ssh_options, { :forward_agent => true }


# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/exp"

# Default value for :format is :airbrussh.
set :format, :airbrussh

set :rack_env, :production

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, "config/secrets.yml"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

set :passenger_restart_with_touch, true
