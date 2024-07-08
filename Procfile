web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -C config/sidekiq_scheduler.yml
release: bundle exec rails db:migrate
