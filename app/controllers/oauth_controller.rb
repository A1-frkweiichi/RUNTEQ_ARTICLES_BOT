require 'googleauth'

class OauthController < ApplicationController
  CREDENTIALS_PATH = ENV.fetch('GMAIL_CREDENTIALS')
  TOKEN_PATH = Rails.root.join('config', 'token.yaml').to_s
  SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_SEND

  def callback
    client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    user_id = 'default'

    credentials = authorizer.get_and_store_credentials_from_code(
      user_id:,
      code: params[:code],
      base_url: oauth2callback_url
    )

    # ENV['GMAIL_TOKEN'] = credentials.to_json # ローカル環境
    Rails.logger.info("GMAIL_TOKEN: #{credentials.to_json}") # 本番環境

    render plain: "認証が完了しました。このウィンドウを閉じて、元の操作を続けてください。"
  end
end
