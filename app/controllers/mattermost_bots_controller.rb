class MattermostBotsController < ApplicationController
  before_action :verify_mattermost_token

  def register_qiita
    user_id = params[:user_id]
    qiita_username = params[:text].to_s.strip

    if qiita_username.empty?
      Rails.logger.info "Qiitaユーザー名が空の状態。Mattermost ID: #{user_id}"
      render json: {
        response_type: 'ephemeral',
        text: "下記のようにQiitaユーザー名も投稿してください\n
               /register_qiita YOUR-QIITA-USERNAME"
      }
      return
    end

    user = User.find_or_initialize_by(mattermost_id: user_id)
    user.qiita_username = qiita_username

    if user.save
      Rails.logger.info "登録成功！Mattermost ID: #{user_id}, Qiitaユーザー名:'#{qiita_username}'"
      render json: {
        response_type: 'ephemeral',
        text: "あなたのユーザー情報の登録に成功しました！:nisemonorantekun: Mattermost ID: #{user_id}, Qiitaユーザー名: #{qiita_username}"
      }
    else
      Rails.logger.error "Qiitaユーザー名 登録失敗。。。Mattermost ID: #{user_id}. Errors: #{user.errors.full_messages.join(', ')}"
      render json: {
        response_type: 'ephemeral',
        text: "登録に失敗しました。。。 :thinking_face: 必要に応じて34期ふるかわにご連絡ください :man-bowing_light_skin_tone: Errors: #{user.errors.full_messages.join(', ')}"
      }
    end
  end

  private

  def verify_mattermost_token
    token = params[:token]
    unless token == ENV['MATTERMOST_BOT_TOKEN']
      render json: { text: 'Unauthorized: TOKENによるエラー' }, status: :unauthorized
    end
  end
end
