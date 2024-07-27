class SendGmailJob < ApplicationJob
  queue_as :default

  def perform
    gmail_service = GmailService.new
    body = generate_email_body
    gmail_service.send_email('qiita.from.runteq@gmail.com', '登録状況推移', body)
  end

  private

  def generate_email_body
    user_count = User.count
    total_articles = Article.count
    active_articles = Article.where(is_postable: true, is_active: true).count
    post_count_stats = generate_post_count_stats

    <<~BODY
      登録ユーザー数: #{user_count}
      登録記事数: #{total_articles}
      投稿対象記事数: #{active_articles}
      投稿対象記事数 内訳
      #{post_count_stats}
    BODY
  end

  def generate_post_count_stats
    stats = Article.where(is_postable: true, is_active: true)
                   .group(:post_count)
                   .count
                   .sort_by { |count, _| count }
                   .map { |count, num| "#{count}回: #{num}" }
                   .join("\n")
    stats.empty? ? "データがありません" : stats
  end
end
