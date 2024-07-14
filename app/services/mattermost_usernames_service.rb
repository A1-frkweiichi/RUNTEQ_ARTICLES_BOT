class MattermostUsernamesService
  def self.sanitize_usernames(submission)
    submission['qiita_username'] = sanitize_username(submission['qiita_username'])
    submission['zenn_username'] = sanitize_username(submission['zenn_username'])
    submission['x_username'] = sanitize_username(submission['x_username'])
  end

  def self.sanitize_username(username)
    username.to_s.strip.sub(/^@/, '')
  end

  def self.validate_usernames(submission)
    errors = {}
    qiita_username = submission['qiita_username'].presence
    zenn_username = submission['zenn_username'].presence

    errors[:qiita_username] = "一致するユーザー名が見つかりません" if qiita_username && !qiita_username_exists?(qiita_username)
    errors[:zenn_username] = "一致するユーザー名が見つかりません" if zenn_username && !zenn_username_exists?(zenn_username)

    errors
  end

  def self.qiita_username_exists?(username)
    response = HTTParty.get("https://qiita.com/api/v2/users/#{username}")
    response.code == 200
  end

  def self.zenn_username_exists?(username)
    response = HTTParty.get("https://zenn.dev/api/users/#{username}")
    response.code == 200
  end
end
