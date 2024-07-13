class PostToXJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 5, backtrace: true
  def perform
    PostToXService.new.call
  end
end
