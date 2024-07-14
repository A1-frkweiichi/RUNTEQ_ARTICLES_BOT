require 'httparty'

class RegisterToMattermostController < ApplicationController
  before_action :verify_mattermost_token, only: [:open_dialog]

  def open_dialog
    user = User.find_by(mattermost_id: params[:user_id])
    dialog_data = MattermostRegistrationService.build_dialog_data(user, request.base_url, params[:trigger_id])

    response = MattermostRegistrationService.send_mattermost_request(dialog_data)
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

    MattermostUsernamesService.sanitize_usernames(submission)

    errors = MattermostUsernamesService.validate_usernames(submission)
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

  def log_validation_errors(errors, user)
    error_messages = errors.map { |field, message| "#{field}: #{message}" }.join(", ")
    Rails.logger.error "登録失敗👀 Mattermost ID: #{user.mattermost_id}. Validation Errors: #{error_messages}"
  end

  def verify_mattermost_token
    return if params[:token] == ENV['MATTERMOST_BOT_TOKEN']

    render json: { text: 'Unauthorized: TOKENによるエラー' }, status: :unauthorized
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
