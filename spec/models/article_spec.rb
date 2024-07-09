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
end
