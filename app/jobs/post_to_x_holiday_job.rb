class PostToXHolidayJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 5, backtrace: true

  def perform
    return unless HolidayJp.holiday?(Date.today)

    PostToXService.new.call
  end
end