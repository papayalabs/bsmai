working_directory "/var/www/bsmai/current"

# Logging
stderr_path "/var/www/bsmai/shared/log/unicorn.stderr.log"
stdout_path "/var/www/bsmai/shared/log/unicorn.stdout.log"

# Set master PID location
pid "/var/www/bsmai/shared/tmp/pids/unicorn.pid"

# Unicorn socket
listen "/var/www/bsmai/shared/tmp/sockets/unicorn.bsmai.sock"


# Number of processes
# worker_processes 4
worker_processes 4

# Time-out
timeout 45

# For development, you may want to listen on port 3000 so that you can make sure
# your unicorn.rb file is soundly configured.
#listen(3000, backlog: 64) if ENV['RAILS_ENV'] == 'development'

listen(9838, backlog: 64) if ENV['RAILS_ENV'] == 'production'