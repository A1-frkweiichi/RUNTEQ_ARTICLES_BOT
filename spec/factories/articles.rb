FactoryBot.define do
  factory :article do
    user
    sequence(:external_id) { |n| "external_#{n}" }
    sequence(:title) { |n| "Article Title #{n}" }
    sequence(:article_url) { |n| "https://example.com/article_#{n}" }
    published_at { Time.current }
    likes_count { 0 }
    source_platform { %w[qiita zenn].sample }
    is_postable { false }
    is_active { true }
    post_count { 0 }
  end
end
