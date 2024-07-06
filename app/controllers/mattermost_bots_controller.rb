require 'httparty'

class MattermostBotsController < ApplicationController
  before_action :verify_mattermost_token, only: [:open_dialog]

  def open_dialog
    user = User.find_by(mattermost_id: params[:user_id])
    dialog_data = build_dialog_data(user)

    response = send_mattermost_request(dialog_data)
    log_mattermost_response(response)

    if response.success?
      render json: { text: "【らんてくん おすすめ記事】登録フォームを開きました" }
    else
      render json: { text: "【らんてくん おすすめ記事】登録フォームを開けませんでした: #{response.body}" }
    end
  end

  def submit_dialog
    return render json: {} if params[:cancelled]

    user = User.find_or_initialize_by(mattermost_id: params[:user_id])
    submission = params[:submission]

    sanitize_usernames(submission)

    errors = validate_usernames(submission)
    if errors.any?
      log_validation_errors(errors, user)
      render json: { errors: }
      return
    end

    update_user_usernames(user, submission)

    if user.save
      log_success_message(user)
      render json: {}
    else
      log_error_message(user)
      render json: { errors: { _error: error_message(user) } }
    end
  end

  private

  def sanitize_usernames(submission)
    submission['qiita_username'] = sanitize_username(submission['qiita_username'])
    submission['zenn_username'] = sanitize_username(submission['zenn_username'])
    submission['x_username'] = sanitize_username(submission['x_username'])
  end

  def sanitize_username(username)
    username.to_s.strip.sub(/^@/, '')
  end

  def validate_usernames(submission)
    errors = {}
    qiita_username = submission['qiita_username'].presence
    zenn_username = submission['zenn_username'].presence

    errors[:qiita_username] = "一致するユーザー名が見つかりません" if qiita_username && !qiita_username_exists?(qiita_username)
    errors[:zenn_username] = "一致するユーザー名が見つかりません" if zenn_username && !zenn_username_exists?(zenn_username)

    errors
  end

  def qiita_username_exists?(username)
    response = HTTParty.get("https://qiita.com/api/v2/users/#{username}")
    response.code == 200
  end

  def zenn_username_exists?(username)
    response = HTTParty.get("https://zenn.dev/api/users/#{username}")
    response.code == 200
  end

  def log_validation_errors(errors, user)
    error_messages = errors.map { |field, message| "#{field}: #{message}" }.join(", ")
    Rails.logger.error "登録失敗👀 Mattermost ID: #{user.mattermost_id}. Validation Errors: #{error_messages}"
  end

  def verify_mattermost_token
    return if params[:token] == ENV['MATTERMOST_BOT_TOKEN']

    render json: { text: 'Unauthorized: TOKENによるエラー' }, status: :unauthorized
  end

  def build_dialog_data(user)
    {
      trigger_id: params[:trigger_id],
      url: "#{request.base_url}/mattermost_bot/submit_dialog",
      dialog: {
        callback_id: "register_dialog",
        title: "【らんてくん おすすめ記事】登録フォーム",
        introduction_text: "RUNTEQ現役・卒業生〜講師陣の高評価記事をお知らせする[X(旧: Twitter)bot](https://x.com/runtekn_rec_art)です。",
        elements: [
          build_username_element("Qiita", user&.qiita_username, nil),
          build_username_element("Zenn", user&.zenn_username, "Qiita もしくは Zennを登録すると記事が紹介対象になります。"),
          build_username_element("X", user&.x_username, "Xを登録すると記事紹介時にメンションされます。")
        ],
        submit_label: "登録",
        notify_on_cancel: true
      }
    }
  end

  def build_username_element(service, username, help_text)
    {
      display_name: "#{service} ユーザー名",
      name: "#{service.downcase}_username",
      type: 'text',
      placeholder: "#{service.downcase}_username",
      optional: true,
      default: username.to_s,
      min_length: 0,
      max_length: 30,
      help_text:
    }
  end

  def send_mattermost_request(dialog_data)
    mattermost_url = "#{ENV['MATTERMOST_URL']}/api/v4/actions/dialogs/open"
    headers = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer #{ENV['MATTERMOST_BOT_TOKEN']}"
    }

    HTTParty.post(mattermost_url, body: dialog_data.to_json, headers:)
  end

  def log_mattermost_response(response)
    Rails.logger.debug "Mattermost response status: #{response.code}"
    Rails.logger.debug "Mattermost response body: #{response.body}"
  end

  def update_user_usernames(user, submission)
    user.qiita_username = submission['qiita_username'].presence
    user.zenn_username = submission['zenn_username'].presence
    user.x_username = submission['x_username'].presence
  end

  def log_success_message(user)
    message = "登録成功！\n" \
      "Mattermost ID: #{user.mattermost_id}\n" \
      "Qiitaユーザー名: #{user.qiita_username || '(削除されました)'}\n" \
      "Zennユーザー名: #{user.zenn_username || '(削除されました)'}\n" \
      "Xユーザー名: #{user.x_username || '(削除されました)'}"
    Rails.logger.info message
  end

  def log_error_message(user)
    Rails.logger.error error_message(user)
  end

  def error_message(user)
    "登録失敗👀 Mattermost ID: #{user.mattermost_id}. Errors: #{user.errors.full_messages.join(', ')}"
  end
end
