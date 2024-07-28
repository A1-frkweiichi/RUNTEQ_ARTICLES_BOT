require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'

class GmailService
  APPLICATION_NAME = 'runtekun-recommends-articles'.freeze
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
    client_id = Google::Auth::ClientId.from_hash(credentials_hash)
    token_hash = Rails.env.production? ? production_token_hash : file_token_hash

    puts "Credentials Hash: #{credentials_hash}"
    puts "Token Hash: #{token_hash}"

    credentials = Google::Auth::UserRefreshCredentials.new(
      client_id: client_id.id,
      client_secret: client_id.secret,
      scope: SCOPE,
      access_token: token_hash['access_token'],
      refresh_token: token_hash['refresh_token'],
      expiration_time_millis: token_hash['expiration_time_millis']
    )

    if credentials.access_token.nil? || credentials.refresh_token.nil?
      puts "Access token or refresh token is missing. Initiating new authorization flow."
      credentials = get_new_credentials(client_id)
    elsif credentials.expired?
      puts "Credentials expired. Refreshing..."
      credentials.refresh!
      save_refreshed_token(credentials)
    end

    puts "Final Credentials: #{credentials.inspect}"
    credentials
  end

  def get_new_credentials(client_id)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, nil)
    user_id = 'default'

    url = authorizer.get_authorization_url(base_url: 'http://localhost:3000/oauth2callback')
    puts "Open this URL in your browser and authorize the application:"
    puts url
    puts "Enter the authorization code:"
    code = gets.chomp

    credentials = authorizer.get_and_store_credentials_from_code(
      user_id:, code:, base_url: 'http://localhost:3000/oauth2callback'
    )

    save_refreshed_token(credentials)
    credentials
  end

  def save_refreshed_token(credentials)
    refreshed_token = {
      'access_token' => credentials.access_token,
      'refresh_token' => credentials.refresh_token,
      'expiration_time_millis' => credentials.expires_at.to_i * 1000
    }

    if Rails.env.production?
      ENV['GMAIL_TOKEN'] = refreshed_token.to_json
    else
      File.write(Rails.root.join('config', 'token.yaml'), refreshed_token.to_yaml)
    end
  end

  def credentials_hash
    @credentials_hash ||= if Rails.env.production?
                            JSON.parse(ENV['GMAIL_CREDENTIALS'] || '{}')
                          else
                            JSON.parse(File.read(Rails.root.join('config', 'Gmail_client_secret.json')))
                          end
  end

  def production_token_hash
    @production_token_hash ||= JSON.parse(ENV['GMAIL_TOKEN'] || '{}')
  end

  def file_token_hash
    @file_token_hash ||= YAML.load_file(Rails.root.join('config', 'token.yaml'))
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
