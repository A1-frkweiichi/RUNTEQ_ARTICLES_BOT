class MattermostRegistrationService
  def self.build_dialog_data(user, base_url, trigger_id)
    {
      trigger_id:,
      url: "#{base_url}/register_to_mattermost/submit_dialog",
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

  def self.build_username_element(service, username, help_text)
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

  def self.send_mattermost_request(dialog_data)
    mattermost_url = "#{ENV.fetch('MATTERMOST_URL', nil)}/api/v4/actions/dialogs/open"
    headers = {
      'Content-Type': 'application/json',
      Authorization: "Bearer #{ENV.fetch('MATTERMOST_BOT_TOKEN', nil)}"
    }

    HTTParty.post(mattermost_url, body: dialog_data.to_json, headers:)
  end
end
