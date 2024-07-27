class User < ApplicationRecord
  has_many :articles
  has_many :posts

  validates :mattermost_id, presence: true, uniqueness: true
  validates :qiita_username, allow_blank: true, uniqueness: true
  validates :zenn_username, allow_blank: true, uniqueness: true
  validates :x_username, allow_blank: true, uniqueness: true

  encrypts :mattermost_id, deterministic: true
  encrypts :qiita_username, deterministic: true
  encrypts :zenn_username, deterministic: true
  encrypts :x_username, deterministic: true
end
