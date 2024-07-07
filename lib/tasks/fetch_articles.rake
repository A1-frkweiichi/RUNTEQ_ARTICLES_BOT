namespace :articles do
  desc "$ rails articles:fetch  コマンドでの動作確認"
  task fetch: :environment do
    FetchArticlesJob.perform_now
  end
end
