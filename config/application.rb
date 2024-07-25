require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RunteqArticlesBot
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))
    config.autoload_paths += %W(#{config.root}/app/services)

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.active_job.queue_adapter = :sidekiq
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore, key: '_runteq_articles_bot_session'
    config.middleware.use Bugsnag::Rack
    config.exceptions_app = routes

    config.active_record.encryption.primary_key = ENV.fetch('ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY', nil)
    config.active_record.encryption.deterministic_key = ENV.fetch('ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY', nil)
    config.active_record.encryption.key_derivation_salt = ENV.fetch('ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT', nil)
  end
end

ENV['GOOGLE_APPLICATION_CREDENTIALS'] ||= Rails.root.join('config', 'GCP_service_account_key.json').to_s
