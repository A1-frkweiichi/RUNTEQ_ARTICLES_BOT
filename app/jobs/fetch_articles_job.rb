class FetchArticlesJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 5, backtrace: true

  def perform(qiita_username = nil, zenn_username = nil)
    if qiita_username || zenn_username
      fetch_for_user(qiita_username, zenn_username)
    else
      User.find_each do |user|
        fetch_for_user(user.qiita_username, user.zenn_username)
      end
    end
  end

  private

  def fetch_for_user(qiita_username, zenn_username)
    Rails.logger.info "Searching for user with Qiita: #{qiita_username}, Zenn: #{zenn_username}"

    user = User.find_by(qiita_username:, zenn_username:)

    if user
      Rails.logger.info "User found with ID: #{user.id}"
      service = ArticleFetcherService.new(user, 1)
      service.fetch_all
    else
      Rails.logger.warn "User not found for Qiita username: #{qiita_username}, Zenn username: #{zenn_username}"
    end
  rescue StandardError => e
    Rails.logger.error "Error in FetchArticlesJob: #{e.message}"
    Bugsnag.notify(e)
  end
end
