require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'

class GmailService
  APPLICATION_NAME = 'runtekun-recommends-articles'.freeze
  CREDENTIALS_PATH = Rails.root.join('config', 'Gmail_client_secret.json').to_s
  TOKEN_PATH = Rails.root.join('config', 'token.yaml').to_s
  SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_SEND

  def initialize
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
    client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    user_id = 'default'

    if Rails.env.production?
      token_data = JSON.parse(ENV['GMAIL_TOKEN'] || '{}')
      credentials = Google::Auth::UserRefreshCredentials.new(
        client_id: client_id.id,
        client_secret: client_id.secret,
        scope: SCOPE,
        access_token: token_data['access_token'],
        refresh_token: token_data['refresh_token'],
        expiration_time_millis: token_data['expiration_time_millis']
      )
    else
      credentials = authorizer.get_credentials(user_id)
    end

    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: 'http://localhost:3000/gmail_oauth2callback')
      puts "Open the following URL in your browser and authorize the application:\n#{url}"
      puts "After authorization, come back and run this script again."
      exit
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
