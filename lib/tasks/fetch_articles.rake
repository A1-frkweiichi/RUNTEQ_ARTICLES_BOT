namespace :articles do
  desc "$ rails articles:fetch, $ rails articles:fetch QIITA_USERNAME=xxx ZENN_USERNAME=yyy"
  task fetch: :environment do
    qiita_username = ENV.fetch('QIITA_USERNAME', nil)
    zenn_username = ENV.fetch('ZENN_USERNAME', nil)

    if qiita_username || zenn_username
      puts "特定ユーザーの記事を取得 Qiita username: #{qiita_username.inspect}, Zenn username: #{zenn_username.inspect}"
      FetchArticlesJob.perform_now(qiita_username, zenn_username)
    else
      puts "全ユーザーの記事を取得"
      FetchArticlesJob.perform_now
    end
  end
end
