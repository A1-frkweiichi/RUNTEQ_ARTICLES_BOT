require 'x'

class PostToXService
  MESSAGE_FILE_PATH = Rails.root.join('x_bot_message.txt')

  def initialize
    @message = read_message_from_file
  end

  def call
    x_credentials = {
      api_key: ENV.fetch('X_API_KEY', nil),
      api_key_secret: ENV.fetch('X_API_KEY_SECRET', nil),
      bearer_token: ENV.fetch('X_BEARER_TOKEN', nil),
      access_token: ENV.fetch('X_ACCESS_TOKEN', nil),
      access_token_secret: ENV.fetch('X_ACCESS_TOKEN_SECRET', nil)
    }

    x_client = X::Client.new(**x_credentials)
    post = x_client.post("tweets", { text: @message }.to_json)
    post["data"]
  rescue StandardError => e
    Rails.logger.error "Failed to post to X: #{e.message}"
    nil
  end

  private

  def read_message_from_file
    File.read(MESSAGE_FILE_PATH).strip
  end
end
