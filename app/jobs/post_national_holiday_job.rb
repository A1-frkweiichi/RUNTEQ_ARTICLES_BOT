require 'custom_holiday'

class PostNationalHolidayJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 5, backtrace: true

  def perform
    today = Date.today
    return unless holiday_today?(today)

    PostToXJob.perform_later
  rescue StandardError => e
    Bugsnag.notify(e)
    raise e
  end

  private

  def holiday_today?(date)
    (CustomHoliday.holiday?(date) || HolidayJp.holiday?(date)) && !date.saturday? && !date.sunday?
  end
end
