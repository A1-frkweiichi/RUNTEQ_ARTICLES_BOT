require 'httparty'

class RegisterToMattermostController < ApplicationController
  before_action :verify_mattermost_token, only: [:open_dialog]

  def open_dialog
    user = User.find_by(mattermost_id: params[:user_id])
    dialog_data = MattermostRegistrationService.build_dialog_data(user, request.base_url, params[:trigger_id])
    response = MattermostRegistrationService.send_mattermost_request(dialog_data)

    log_mattermost_response(response)

    render json: { text: response.success? ? "【らんてくん おすすめ記事】登録フォームを開きました" : "【らんてくん おすすめ記事】登録フォームを開けませんでした: #{response.body}" }
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

  def verify_mattermost_token
    render json: { text: 'Unauthorized: TOKENによるエラー' }, status: :unauthorized unless params[:token] == ENV['MATTERMOST_BOT_TOKEN']
  end

  def update_user_usernames(user, submission)
    previous_qiita_username = user.qiita_username
    previous_zenn_username = user.zenn_username

    user.qiita_username = submission['qiita_username'].presence
    user.zenn_username = submission['zenn_username'].presence
    user.x_username = submission['x_username'].presence

    update_articles_activity(user, previous_qiita_username, previous_zenn_username)
  end

  def update_articles_activity(user, previous_qiita_username, previous_zenn_username)
    Article.where(user_id: user.id, source_platform: 'qiita').update_all(is_active: user.qiita_username.present?) if user.qiita_username != previous_qiita_username
    Article.where(user_id: user.id, source_platform: 'zenn').update_all(is_active: user.zenn_username.present?) if user.zenn_username != previous_zenn_username
  end

  def log_mattermost_response(response)
    Rails.logger.debug "Mattermost response status: #{response.code}"
    Rails.logger.debug "Mattermost response body: #{response.body}"
  end

  def log_validation_errors(errors, user)
    error_messages = errors.map { |field, message| "#{field}: #{message}" }.join(", ")
    Rails.logger.error "登録失敗👀 Mattermost ID: #{user.mattermost_id}. Validation Errors: #{error_messages}"
  end

  def log_success_message(user)
    message = <<~MSG
      登録成功！
      Mattermost ID: #{user.mattermost_id}
      Qiitaユーザー名: #{user.qiita_username || '(削除されました)'}
      Zennユーザー名: #{user.zenn_username || '(削除されました)'}
      Xユーザー名: #{user.x_username || '(削除されました)'}
    MSG
    Rails.logger.info message
  end

  def log_error_message(user)
    Rails.logger.error error_message(user)
  end

  def error_message(user)
    "登録失敗👀 Mattermost ID: #{user.mattermost_id}. Errors: #{user.errors.full_messages.join(', ')}"
  end
end
