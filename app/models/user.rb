class User < ApplicationRecord
  has_many :articles

  validates :mattermost_id, presence: true, uniqueness: true
  validates :qiita_username, allow_blank: true, uniqueness: true
  validates :zenn_username, allow_blank: true, uniqueness: true
  validates :x_username, allow_blank: true, uniqueness: true
end
