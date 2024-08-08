require_relative '../models/concerns/record_post_params'

class PostJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 5, backtrace: true

  def perform
    post_to_x_service = PostToXService.new
    post_to_x_service.call

    # record_in_sheets(post_to_x_service.post, post_to_x_service.article)
  rescue StandardError => e
    Bugsnag.notify(e)
    raise e
  end

  # private
  #
  # def record_in_sheets(post, article)
  #   params = RecordPostParams.new(
  #     post.id,
  #     article.title,
  #     article.article_url,
  #     article.user.x_username,
  #     article.source_platform_hashtag,
  #     post.created_at
  #   )
  #
  #   GoogleSheetsService.new.record_post(params)
  # rescue StandardError => e
  #   Bugsnag.notify(e)
  #   raise e
  # end
end
