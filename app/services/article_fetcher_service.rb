require 'httparty'

class ArticleFetcherService
  QIITA_RATE_LIMIT = 1000 # 1時間あたりの最大リクエスト数: 10,000記事相当
  QIITA_RATE_WINDOW = 3600 # 1時間（秒）
  ZENN_RATE_LIMIT = 5 # 15分あたりの最大リクエスト数: 240記事相当
  ZENN_RATE_WINDOW = 900 # 15分（秒）

  def self.fetch_for_user(user)
    new(user).fetch_all
  end

  def initialize(user)
    @user = user
    @rate_limits = {
      qiita: { requests: 0, window_start: Time.now },
      zenn: { requests: 0, window_start: Time.now }
    }
  end

  def fetch_all
    %w[qiita zenn].each do |platform|
      fetch_articles(platform) if @user.send("#{platform}_username").present?
    end
  end

  private

  def fetch_articles(platform)
    page = 1
    total_count = 0

    loop do
      response = fetch_page(platform, page)
      break if response_invalid?(response)

      articles = parse_articles(response, platform)
      break if articles.empty?

      save_articles(articles, platform)

      total_count += articles.size
      break if should_stop_fetching?(total_count, response, platform, articles)

      page += 1
    end
  end

  def fetch_page(platform, page)
    wait_for_rate_limit(platform)
    url = build_url(platform, page)
    response = HTTParty.get(url, headers: headers_for(platform))
    @rate_limits[platform.to_sym][:requests] += 1
    response
  end

  def wait_for_rate_limit(platform)
    limit = self.class.const_get("#{platform.upcase}_RATE_LIMIT")
    window = self.class.const_get("#{platform.upcase}_RATE_WINDOW")
    rate_info = @rate_limits[platform.to_sym]

    return unless rate_info[:requests] >= limit

    elapsed = Time.now - rate_info[:window_start]
    sleep(window - elapsed) if elapsed < window
    rate_info[:requests] = 0
    rate_info[:window_start] = Time.now
  end

  def build_url(platform, page)
    case platform
    when 'qiita'
      "https://qiita.com/api/v2/users/#{@user.qiita_username}/items?page=#{page}&per_page=100"
    when 'zenn'
      "https://zenn.dev/api/articles?username=#{@user.zenn_username}&order=latest&page=#{page}"
    end
  end

  def headers_for(platform)
    platform == 'qiita' ? qiita_headers : {}
  end

  def response_invalid?(response)
    response.code != 200 || response.body.nil? || response.body.empty?
  end

  def parse_articles(response, platform)
    data = JSON.parse(response.body)
    platform == 'zenn' ? data['articles'] : data
  end

  def should_stop_fetching?(total_count, response, platform, articles)
    case platform
    when 'qiita'
      total_count >= response.headers['total-count'].to_i || articles.empty?
    when 'zenn'
      data = JSON.parse(response.body)
      data['total_count'].nil? ? articles.size < 48 : total_count >= data['total_count'].to_i
    end
  end

  def save_articles(articles, platform)
    articles.each { |article| save_article(article, platform) }
  end

  def save_article(article_data, platform)
    article = @user.articles.find_or_initialize_by(
      source_platform: platform,
      external_id: article_data['id']
    )

    article.assign_attributes(
      title: article_data['title'],
      article_url: article_url(article_data, platform),
      published_at: published_at(article_data, platform),
      likes_count: likes_count(article_data, platform)
    )

    article.save!
  end

  def article_url(article_data, platform)
    platform == 'qiita' ? article_data['url'] : "https://zenn.dev#{article_data['path']}"
  end

  def published_at(article_data, platform)
    platform == 'qiita' ? article_data['created_at'] : article_data['published_at']
  end

  def likes_count(article_data, platform)
    platform == 'qiita' ? article_data['likes_count'] : article_data['liked_count']
  end

  def qiita_headers
    {
      'Authorization' => "Bearer #{ENV['QIITA_ACCESS_TOKEN']}",
      'Content-Type' => 'application/json'
    }
  end
end
