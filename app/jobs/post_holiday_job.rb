RecordPostParams = Struct.new(:post_id, :article_title, :article_url, :x_username, :hashtag, :created_at)

class PostHolidayJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 5, backtrace: true

  def perform
    return unless HolidayJp.holiday?(Date.today)
    return if Date.today.saturday? || Date.today.sunday?

    post_to_x_service = PostToXService.new
    post_to_x_service.call

    record_in_sheets(post_to_x_service.post, post_to_x_service.article)
  rescue StandardError => e
    Bugsnag.notify(e)
    raise e
  end

  private

  def record_in_sheets(post, article)
    params = RecordPostParams.new(
      post.id,
      article.title,
      article.article_url,
      article.user.x_username,
      article.source_platform_hashtag,
      post.created_at
    )

    GoogleSheetsService.new.record_post(params)
  rescue StandardError => e
    Bugsnag.notify(e)
    raise e
  end
end
