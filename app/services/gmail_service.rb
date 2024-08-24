require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'logger'

class GmailService
  APPLICATION_NAME = 'runtekun-recommends-articles'.freeze
  CREDENTIALS_PATH = ENV.fetch('GMAIL_CREDENTIALS')
  TOKEN_PATH = Rails.root.join('config', 'token.yaml').to_s
  SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_SEND

  def initialize
    @logger = Logger.new($stdout)
    @service = Google::Apis::GmailV1::GmailService.new
    @service.client_options.application_name = APPLICATION_NAME
    @service.authorization = authorize
  end

  def send_email(to, subject, body)
    message = Google::Apis::GmailV1::Message.new(
      raw: create_message(to, subject, body)
    )
    @service.send_user_message('me', message)
  end

  private

  def authorize
    @logger.info("Starting authorization process...")
    @logger.info("Credentials path: #{CREDENTIALS_PATH}")
    @logger.info("Token store path: #{TOKEN_PATH}")

    client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    user_id = 'default'

    credentials = if Rails.env.production?
                    if ENV['GMAIL_TOKEN'].present?
                      token_data = JSON.parse(ENV['GMAIL_TOKEN'])
                      Google::Auth::UserRefreshCredentials.new(
                        client_id: client_id.id,
                        client_secret: client_id.secret,
                        scope: SCOPE,
                        access_token: token_data['access_token'],
                        refresh_token: token_data['refresh_token'],
                        expiration_time_millis: token_data['expiration_time_millis']
                      )
                    else
                      @logger.error("GMAIL_TOKEN is not set or invalid.")
                      nil
                    end
                  else
                    @logger.info("Using development credentials.")
                    authorizer.get_credentials(user_id)
                  end

    if credentials.nil?
      base_url = ENV.fetch('OAUTH_CALLBACK_URL', 'http://localhost:3000/oauth2callback')
      url = authorizer.get_authorization_url(base_url:)
      @logger.error("Authorization required. Please visit the URL: #{url}")
      raise "Authorization failed. Please visit the URL to authorize the application."
    else
      if credentials.expired?
        @logger.info("Access token expired. Refreshing token...")
        credentials.refresh!
        @logger.info("Token refreshed successfully.")
        ENV['GMAIL_TOKEN'] = credentials.to_json if Rails.env.production?
      end
      @logger.info("Authorization successful.")
    end

    credentials
  end

  def create_message(to, subject, body)
    message = Mail.new do
      to to
      subject subject
      body body
    end
    message.to_s
  end
end
