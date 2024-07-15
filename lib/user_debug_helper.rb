module UserDebugHelper
  def self.debug_find_encrypted(qiita_username, zenn_username)
    Rails.logger.debug "Searching for Qiita: #{qiita_username}, Zenn: #{zenn_username}"

    user = find_by(qiita_username:, zenn_username:)

    if user
      Rails.logger.debug "User found: #{user.inspect}"
      Rails.logger.debug "Qiita username encrypted: #{user.encrypted_attribute?(:qiita_username)}"
      Rails.logger.debug "Zenn username encrypted: #{user.encrypted_attribute?(:zenn_username)}"
      Rails.logger.debug "Qiita username ciphertext: #{user.ciphertext_for(:qiita_username)}"
      Rails.logger.debug "Zenn username ciphertext: #{user.ciphertext_for(:zenn_username)}"
    else
      Rails.logger.debug "User not found"
      encrypted_qiita = User.encrypt_qiita_username(qiita_username)
      encrypted_zenn = User.encrypt_zenn_username(zenn_username)
      direct_user = find_by("qiita_username = ? OR zenn_username = ?", encrypted_qiita, encrypted_zenn)
      Rails.logger.debug "Direct search result: #{direct_user.inspect}"
    end

    user
  end

  def self.encrypt_qiita_username(value)
    encrypted_attribute(:qiita_username).encrypt(value)
  end

  def self.encrypt_zenn_username(value)
    encrypted_attribute(:zenn_username).encrypt(value)
  end
end
