class RecordPostInSheetsJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 5, backtrace: true

  def perform(post, article)
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
