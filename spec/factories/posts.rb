FactoryBot.define do
  factory :post do
    association :article
    status { "pending" }
    created_at { Time.current }
    updated_at { Time.current }
    association :user
  end
end
