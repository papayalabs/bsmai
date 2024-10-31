#web: bundle exec puma -C /var/www/bsmai/shared/config/puma.rb -e production
#worker: RAILS_ENV=production bundle exec bin/rake solid_queue:start
web: RAILS_ENV=production RUN_SOLID_QUEUE_IN_PUMA=true bin/rails server -p ${PORT:-9838}