require 'httparty'

class ArticleFetcherService
  def self.fetch_for_user(user, years = 1)
    new(user, years).fetch_all
  end

  def initialize(user, years)
    @user = user
    @years = years
    @qiita_fetcher = PlatformArticleFetcher.new(user, 'qiita', years)
    @zenn_fetcher = PlatformArticleFetcher.new(user, 'zenn', years)
  end

  def fetch_all
    @qiita_fetcher.fetch_articles if @user.qiita_username.present?
    @zenn_fetcher.fetch_articles if @user.zenn_username.present?
  end
end
