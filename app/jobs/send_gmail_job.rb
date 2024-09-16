class SendGmailJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 5, backtrace: true, unique: :until_and_while_executing

  def perform
    gmail_service = GmailService.new
    body = generate_email_body
    gmail_service.send_email('qiita.from.runteq@gmail.com', '【らんてくん おすすめ記事】登録状況 📈👀', body)
  rescue StandardError => e
    Bugsnag.notify(e)
    raise e
  end

  private

  def generate_email_body
    user_count = User.count
    total_articles = Article.count
    postable_articles = Article.where(is_postable: true, is_active: true).count
    post_count_stats = generate_post_count_stats

    qiita_user_count = User.where.not(qiita_username: nil).count
    qiita_usernames = User.pluck(:qiita_username).compact.join("\n")

    zenn_user_count = User.where.not(zenn_username: nil).count
    zenn_usernames = User.pluck(:zenn_username).compact.join("\n")

    qiita_article_count = Article.where(is_postable: true, is_active: true).qiita.count
    zenn_article_count = Article.where(is_postable: true, is_active: true).zenn.count

    <<~BODY
      【投稿状況】

      #{post_count_stats}

      ------------------------------

      【登録記事の合計数】 #{total_articles}

      【投稿対象の記事数】 #{postable_articles}
      ・Qiita: #{qiita_article_count}
      ・Zenn: #{zenn_article_count}

      ------------------------------

      【ユーザーの合計数】 #{user_count}

      ・Qiita: #{qiita_user_count}
      #{qiita_usernames}

      ・Zenn: #{zenn_user_count}
      #{zenn_usernames}

      ------------------------------

      ステキで充実した週末を！！🙋‍♂️✨
    BODY
  end

  def generate_post_count_stats
    stats = Article.where(is_postable: true, is_active: true)
                   .group(:post_count)
                   .count
                   .sort_by { |count, _| count }
                   .map { |count, num| "#{count}回投稿済み: #{num}" }
                   .join("\n")
    stats.empty? ? "データがありません" : stats
  end
end
