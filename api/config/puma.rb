# frozen_string_literal: true

# Puma configuration file for production Rails API
# See https://github.com/puma/puma/blob/master/lib/puma/dsl.rb

# Thread pool size
max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 5)
min_threads_count = ENV.fetch('RAILS_MIN_THREADS') { max_threads_count }
threads min_threads_count, max_threads_count

# Workers (processes)
# WEB_CONCURRENCY should be set based on available memory
# Rule of thumb: (Total RAM - 1GB for OS) / 512MB per worker
workers ENV.fetch('WEB_CONCURRENCY', 2)

# Use clustered mode in production
preload_app! if ENV.fetch('RAILS_ENV', 'development') == 'production'

# Port binding
port ENV.fetch('PORT', 3000)

# Environment
environment ENV.fetch('RAILS_ENV', 'development')

# PID file
pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')

# Allow puma to be restarted by `bin/rails restart` command
plugin :tmp_restart

# Logging
stdout_redirect 'log/puma.stdout.log', 'log/puma.stderr.log', true if ENV['RAILS_ENV'] == 'production'

# Worker boot callback
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# Before fork callback (preload_app only)
before_fork do
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end

# Lowlevel error handler
lowlevel_error_handler do |e, _env|
  [
    500,
    { 'Content-Type' => 'application/json' },
    [{ error: 'Internal Server Error', message: e.message }.to_json]
  ]
end
