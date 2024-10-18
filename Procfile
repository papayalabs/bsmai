web: bundle exec puma -C /var/www/bsmai/shared/config/puma.rb -e production
worker: RAILS_ENV=production bundle exec bin/rake solid_queue:start

