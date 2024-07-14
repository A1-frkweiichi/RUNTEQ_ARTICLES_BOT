require 'rails_helper'

RSpec.describe Article, type: :model do
  let(:user) { create(:user) }
  let(:article) { build(:article, user:) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(article).to be_valid
    end

    it 'is not valid without a user' do
      article.user = nil
      expect(article).to_not be_valid
    end

    it 'is not valid without a source_platform' do
      article.source_platform = nil
      expect(article).to_not be_valid
    end

    it 'is not valid without an external_id' do
      article.external_id = nil
      expect(article).to_not be_valid
    end

    it 'is not valid with a duplicate external_id' do
      create(:article, user:, external_id: article.external_id)
      expect(article).to_not be_valid
    end

    it 'is not valid without a title' do
      article.title = nil
      expect(article).to_not be_valid
    end

    it 'is not valid without an article_url' do
      article.article_url = nil
      expect(article).to_not be_valid
    end

    it 'is not valid without a published_at date' do
      article.published_at = nil
      expect(article).to_not be_valid
    end

    it 'is not valid without a likes_count' do
      article.likes_count = nil
      expect(article).to_not be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a user' do
      expect(article.user).to eq(user)
    end
  end

  describe '.random_postable_article' do
    it 'returns a postable article' do
      create(:article, user:, is_postable: true, is_active: true)
      create(:article, user:, is_postable: false, is_active: true)
      create(:article, user:, is_postable: true, is_active: false)

      postable_article = Article.random_postable_article
      expect(postable_article.is_postable).to be_truthy
      expect(postable_article.is_active).to be_truthy
    end
  end

  describe '#update_postable_status' do
    it 'updates the is_postable status based on likes_count and published_at' do
      article.update(published_at: 6.months.ago, likes_count: 31, source_platform: 'qiita')
      article.update_postable_status
      expect(article.is_postable).to be_truthy

      article.update(likes_count: 10)
      article.update_postable_status
      expect(article.is_postable).to be_falsey
    end
  end

  describe '#source_platform_hashtag' do
    it 'returns the correct hashtag for Qiita' do
      article.source_platform = 'qiita'
      expect(article.source_platform_hashtag).to eq('#Qiita')
    end

    it 'returns the correct hashtag for Zenn' do
      article.source_platform = 'zenn'
      expect(article.source_platform_hashtag).to eq('#Zenn')
    end
  end
end
