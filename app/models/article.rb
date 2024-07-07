class Article < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :source_platform, presence: true
  validates :external_id, presence: true, uniqueness: true
  validates :title, presence: true
  validates :article_url, presence: true
  validates :published_at, presence: true
  validates :likes_count, presence: true

  enum source_platform: { qiita: 'qiita', zenn: 'zenn' }
end
