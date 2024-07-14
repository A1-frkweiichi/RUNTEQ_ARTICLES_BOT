class PostToXHolidayJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 5, backtrace: true

  def perform
    return unless HolidayJp.holiday?(Date.today)
    return if Date.today.saturday? || Date.today.sunday?

    PostToXService.new.call
  rescue StandardError => e
    Bugsnag.notify(e)
    raise e
  end
end
