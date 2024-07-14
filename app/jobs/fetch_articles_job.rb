class FetchArticlesJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 5, backtrace: true

  def perform(*args)
    user = User.find(args[0])
    service = ArticleFetcherService.new(user, 1)
    service.fetch_all
  rescue StandardError => e
    Bugsnag.notify(e)
  end
end
