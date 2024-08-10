namespace :post do
  desc "$ rails post:execute 投稿タスク"
  task execute: :environment do
    PostToXJob.perform_now
  end
end
