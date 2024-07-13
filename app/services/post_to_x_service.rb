require 'x'
require 'erb'
require 'bugsnag'

class PostToXService
  TEMPLATE_PATH = Rails.root.join('x_bot_message.txt')

  def initialize
    @article = Article.random_postable_article
    @post = @article.posts.create!(status: :pending)
  end

  def call
    return unless @article

    x_client = initialize_x_client
    message = generate_message
    post_response = x_client.post("tweets", { text: message }.to_json)

    handle_response(post_response)
  rescue StandardError => e
    handle_error(e)
    nil
  end

  private

  def initialize_x_client
    x_credentials = {
      api_key: ENV.fetch('X_API_KEY', nil),
      api_key_secret: ENV.fetch('X_API_KEY_SECRET', nil),
      bearer_token: ENV.fetch('X_BEARER_TOKEN', nil),
      access_token: ENV.fetch('X_ACCESS_TOKEN', nil),
      access_token_secret: ENV.fetch('X_ACCESS_TOKEN_SECRET', nil)
    }
    X::Client.new(**x_credentials)
  end

  def generate_message
    template = File.read(TEMPLATE_PATH)
    ERB.new(template).result(binding)
  end

  def japanese_day_of_week
    %w[日 月 火 水 木 金 土][Time.jst.wday]
  end

  def handle_response(post_response)
    if post_response["data"]
      @post.update!(status: :success)
      @article.increment!(:post_count)
    else
      @post.update!(status: :failed)
    end
    post_response["data"]
  end

  def handle_error(exception)
    notify_bugsnag(exception)
    @post.update!(status: :failed)
    Rails.logger.error "Failed to post to X: #{exception.message}"
  end

  def notify_bugsnag(exception)
    Bugsnag.notify(exception) do |report|
      report.add_tab(:custom, {
                       post_id: @post.id,
                       article_id: @article.id
                     })
    end
  end
end
