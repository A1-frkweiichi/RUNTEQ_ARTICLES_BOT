require 'googleauth'

class OauthController < ApplicationController
  def callback
    client_id = Google::Auth::ClientId.from_file(Rails.root.join('config', 'Gmail_client_secret.json'))
    token_store = Google::Auth::Stores::FileTokenStore.new(file: Rails.root.join('config', 'token.yaml'))
    authorizer = Google::Auth::UserAuthorizer.new(client_id, Google::Apis::GmailV1::AUTH_GMAIL_SEND, token_store)
    user_id = 'default'

    authorizer.get_and_store_credentials_from_code(
      user_id:,
      code: params[:code],
      base_url: oauth2callback_url
    )

    render plain: "認証が完了しました。このウィンドウを閉じて、元の操作を続けてください。"
  end
end
