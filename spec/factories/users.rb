FactoryBot.define do
  factory :user do
    mattermost_id { "test_user_id" }
    qiita_username { "test_qiita" }
    zenn_username { "test_zenn" }
  end
end
