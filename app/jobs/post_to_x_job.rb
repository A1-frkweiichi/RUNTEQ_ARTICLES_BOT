require 'date_helper'

class PostToXJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 5, backtrace: true

  def perform
    today = Date.today

    if DateHelper.should_post_today?(today)
      execute_posting_logic
    else
      Rails.logger.info "例外処理: #{Time.current}"
    end
  rescue StandardError => e
    Bugsnag.notify(e)
    raise e
  end

  private

  def execute_posting_logic
    post_to_x_service = PostToXService.new
    post_to_x_service.call

    return unless post_to_x_service.post.present?

    post = post_to_x_service.post
    post.update(status: :pending)

    params = {
      article_id: post_to_x_service.article.id
    }
    RecordPostInSheetsJob.perform_later(**params)
    Rails.logger.info "Enqueuing RecordPostInSheetsJob with params: #{params.inspect}"
  end
end
