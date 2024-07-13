class Article < ApplicationRecord
  belongs_to :user
  has_many :posts

  validates :user_id, presence: true
  validates :source_platform, presence: true
  validates :external_id, presence: true, uniqueness: true
  validates :title, presence: true
  validates :article_url, presence: true
  validates :published_at, presence: true
  validates :likes_count, presence: true

  enum source_platform: { qiita: 'qiita', zenn: 'zenn' }

  REQUIRED_LIKES = {
    'qiita' => 25,
    'zenn' => 20
  }.freeze

  def update_postable_status(years = 1)
    years_since_published = ((Time.current - published_at.to_time) / 1.year).to_i
    required_likes = REQUIRED_LIKES[source_platform] || 0

    self.is_postable = years_since_published < years && likes_count >= required_likes
    save
  end

  def self.random_postable_article
    where(is_postable: true).order('RANDOM()').first
  end

  def source_platform_hashtag
    case source_platform
    when 'qiita'
      '#Qiita'
    when 'zenn'
      '#Zenn'
    else
      ''
    end
  end
end
