server 'isascam.com', user: 'deploy', roles: %w{app web}
set :bundle_jobs, 1
set :migration_role, :app
set :passenger_restart_with_touch, false
