require 'httparty'

class PlatformArticleFetcher
  QIITA_RATE_LIMIT = 1000 # 60分あたりの最大リクエスト数: 最大10,000記事
  QIITA_RATE_WINDOW = 3600 # 60分（秒）
  ZENN_RATE_LIMIT = 10 # 10分あたりの最大リクエスト数: 最大480記事
  ZENN_RATE_WINDOW = 600 # 10分（秒）

  def initialize(user, platform, years)
    @user = user
    @platform = platform
    @years = years
    @rate_limits = { requests: 0, window_start: Time.now }
  end

  def fetch_articles
    page = 1
    total_count = 0

    loop do
      response = fetch_page(page)
      break if response_invalid?(response)

      articles = parse_articles(response)
      break if articles.empty?

      articles.each do |article_data|
        save_article(article_data)
      end

      total_count += articles.size
      break if should_stop_fetching?(total_count, response, articles)

      page += 1
    rescue StandardError => e
      notify_bugsnag(e)
      Rails.logger.error "Failed to fetch articles for #{@platform}. Error: #{e.message}"
      break
    end
  end

  private

  def fetch_page(page)
    wait_for_rate_limit
    url = build_url(page)
    response = HTTParty.get(url, headers:)
    @rate_limits[:requests] += 1
    response
  end

  def wait_for_rate_limit
    limit = self.class.const_get("#{@platform.upcase}_RATE_LIMIT")
    window = self.class.const_get("#{@platform.upcase}_RATE_WINDOW")

    return unless @rate_limits[:requests] >= limit

    elapsed = Time.now - @rate_limits[:window_start]
    sleep(window - elapsed) if elapsed < window
    @rate_limits[:requests] = 0
    @rate_limits[:window_start] = Time.now
  end

  def build_url(page)
    case @platform
    when 'qiita'
      "https://qiita.com/api/v2/users/#{@user.qiita_username}/items?page=#{page}&per_page=100"
    when 'zenn'
      "https://zenn.dev/api/articles?username=#{@user.zenn_username}&order=latest&page=#{page}"
    end
  end

  def headers
    @platform == 'qiita' ? qiita_headers : {}
  end

  def response_invalid?(response)
    response.code != 200 || response.body.nil? || response.body.empty?
  end

  def parse_articles(response)
    data = JSON.parse(response.body)
    @platform == 'zenn' ? data['articles'] : data
  end

  def should_stop_fetching?(total_count, response, articles)
    case @platform
    when 'qiita'
      total_count >= response.headers['total-count'].to_i || articles.empty?
    when 'zenn'
      articles.size < 48 || (JSON.parse(response.body)['total_count'] && total_count >= JSON.parse(response.body)['total_count'].to_i)
    end
  end

  def save_article(article_data)
    article = @user.articles.find_or_initialize_by(
      source_platform: @platform,
      external_id: article_data['id']
    )

    article.assign_attributes(
      title: article_data['title'],
      article_url: article_url(article_data),
      published_at: published_at(article_data),
      likes_count: likes_count(article_data)
    )

    article.save!
    article.update_postable_status(@years)
  end

  def article_url(article_data)
    @platform == 'qiita' ? article_data['url'] : "https://zenn.dev#{article_data['path']}"
  end

  def published_at(article_data)
    @platform == 'qiita' ? article_data['created_at'] : article_data['published_at']
  end

  def likes_count(article_data)
    @platform == 'qiita' ? article_data['likes_count'] : article_data['liked_count']
  end

  def qiita_headers
    {
      'Authorization' => "Bearer #{ENV.fetch('QIITA_ACCESS_TOKEN', nil)}",
      'Content-Type' => 'application/json'
    }
  end

  def notify_bugsnag(exception)
    Bugsnag.notify(exception) do |report|
      report.add_tab(:custom, {
                       user_id: @user.id,
                       platform: @platform
                     })
    end
  end
end
