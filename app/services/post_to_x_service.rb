require 'x'
require 'erb'

class PostToXService
  TEMPLATE_PATH = Rails.root.join('x_bot_message.txt')

  def initialize
    @article = Article.random_postable_article
  end

  def call
    return unless @article

    x_credentials = {
      api_key: ENV.fetch('X_API_KEY', nil),
      api_key_secret: ENV.fetch('X_API_KEY_SECRET', nil),
      bearer_token: ENV.fetch('X_BEARER_TOKEN', nil),
      access_token: ENV.fetch('X_ACCESS_TOKEN', nil),
      access_token_secret: ENV.fetch('X_ACCESS_TOKEN_SECRET', nil)
    }

    x_client = X::Client.new(**x_credentials)
    message = generate_message
    post = x_client.post("tweets", { text: message }.to_json)
    post["data"]
  rescue StandardError => e
    Rails.logger.error "Failed to post to X: #{e.message}"
    nil
  end

  private

  def generate_message
    template = File.read(TEMPLATE_PATH)
    ERB.new(template).result(binding)
  end

  def source_platform_hashtag(platform)
    case platform
    when 'qiita'
      '#Qiita'
    when 'zenn'
      '#Zenn'
    else
      ''
    end
  end
end
