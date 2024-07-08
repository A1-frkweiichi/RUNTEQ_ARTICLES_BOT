require 'sidekiq'
require 'sidekiq-scheduler'
require 'sidekiq/web'

Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV['REDIS_TLS_URL'] || 'redis://localhost:6379/0',
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }

  config.on(:startup) do
    schedule_file = File.expand_path('../sidekiq_scheduler.yml', __dir__)
    if File.exist?(schedule_file)
      begin
        Sidekiq.schedule = YAML.load_file(schedule_file)
        SidekiqScheduler::Scheduler.instance.reload_schedule!
      rescue StandardError => e
        Rails.logger.error "Failed to load Sidekiq schedule: #{e.message}"
      end
    else
      Rails.logger.warn "Sidekiq schedule file not found: #{schedule_file}"
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV['REDIS_TLS_URL'] || 'redis://localhost:6379/0',
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }
end

if Rails.env.production?
  Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
    [user, password] == [ENV['SIDEKIQ_WEB_USER'], ENV['SIDEKIQ_WEB_PASSWORD']]
  end
end
