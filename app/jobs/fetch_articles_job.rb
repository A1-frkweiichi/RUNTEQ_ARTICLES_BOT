class FetchArticlesJob < ApplicationJob
  queue_as :default

  def perform
    User.find_each do |user|
      ArticleFetcherService.fetch_for_user(user)
    end
  end
end
