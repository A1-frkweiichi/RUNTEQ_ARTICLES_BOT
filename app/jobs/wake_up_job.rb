class WakeUpJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 5, backtrace: true

  def perform
    Rails.logger.info("Success: Wake Up Worker Dyno.")
  rescue StandardError => e
    Bugsnag.notify(e)
    raise e
  end
end
