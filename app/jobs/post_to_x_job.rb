require 'date_helper'
require_relative '../models/concerns/record_post_params'

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

    Rails.logger.info "Enqueuing RecordPostInSheetsJob for Post ID: #{post_to_x_service.post.id}, Article ID: #{post_to_x_service.article.id}"
    RecordPostInSheetsJob.perform_later(post_to_x_service.post.id, post_to_x_service.article.id)
  end
end
