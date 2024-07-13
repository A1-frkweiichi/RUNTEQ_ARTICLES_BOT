class FetchArticlesJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 5, backtrace: true

  def perform
    User.find_each do |user|
      ArticleFetcherService.fetch_for_user(user)
    end
  end
end
