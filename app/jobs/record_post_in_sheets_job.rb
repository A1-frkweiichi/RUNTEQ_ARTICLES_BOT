class RecordPostInSheetsJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 5, backtrace: true, unique: :until_and_while_executing

  def perform(params)
    article = Article.find_by(id: params[:article_id])

    if article.nil?
      Rails.logger.warn "Article not found. Article ID: #{params[:article_id]}"
      return
    end

    begin
      params[:article_title] = article.title
      params[:article_url] = article.article_url
      params[:x_username] = article.user.x_username
      params[:hashtag] = article.source_platform_hashtag

      Rails.logger.info "Params: #{params.inspect}"
      GoogleSheetsService.new.record_post(params)
    rescue StandardError => e
      Rails.logger.error "Error in RecordPostInSheetsJob: #{e.message}"
      Bugsnag.notify(e)
      raise e
    end
  end
end
