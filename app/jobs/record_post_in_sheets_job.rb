class RecordPostInSheetsJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 5, backtrace: true

  def perform(post_id, article_id)
    post = Post.find_by(id: post_id)
    article = Article.find_by(id: article_id)

    if post.nil? || article.nil?
      Rails.logger.warn "Post or Article not found. Post ID: #{post_id}, Article ID: #{article_id}"
      return
    end

    params = RecordPostParams.new(
      post.id,
      article.title,
      article.article_url,
      article.user.x_username,
      article.source_platform_hashtag,
      post.created_at
    )

    Rails.logger.info "Params: #{params.inspect}"
    GoogleSheetsService.new.record_post(params)
  rescue StandardError => e
    Rails.logger.error "Error in RecordPostInSheetsJob: #{e.message}"
    Bugsnag.notify(e)
    raise e
  end
end
