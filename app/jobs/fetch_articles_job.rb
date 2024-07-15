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
    conditions = {}
    conditions[:qiita_username] = qiita_username if qiita_username
    conditions[:zenn_username] = zenn_username if zenn_username

    user = User.find_by(conditions)
    if user
      service = ArticleFetcherService.new(user, 1)
      service.fetch_all
    else
      Rails.logger.error "User not found for Qiita username: #{qiita_username.inspect}, Zenn username: #{zenn_username.inspect}"
    end
  rescue StandardError => e
    Rails.logger.error "Error in FetchArticlesJob for user Qiita: #{qiita_username.inspect}, Zenn: #{zenn_username.inspect}: #{e.message}"
    Bugsnag.notify(e)
  end
end
