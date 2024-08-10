require_relative '../models/concerns/record_post_params'

class PostToXJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 5, backtrace: true

  def perform
    post_to_x_service = PostToXService.new
    post_to_x_service.call

    RecordPostInSheetsJob.perform_later(post_to_x_service.post, post_to_x_service.article) if post_to_x_service.post.present?
  rescue StandardError => e
    Bugsnag.notify(e)
    raise e
  end
end
