require 'rails_helper'

RSpec.describe ArticleFetcherService do
  let(:user) { create(:user) }
  let(:service) { described_class.new(user, 1) }

  describe '#fetch_all' do
    before do
      stub_qiita_api(user.qiita_username, 'qiita_1', 'qiita_2')
      stub_zenn_api(user.zenn_username, 'zenn_1', 'zenn_2')
    end

    it 'fetches articles from both platforms' do
      expect { service.fetch_all }.to change { Article.count }.by(4)
    end

    it 'fetches and saves articles with correct attributes' do
      service.fetch_all

      qiita_article = Article.find_by(source_platform: 'qiita', external_id: 'qiita_1')
      expect(qiita_article).to have_attributes(
        title: 'Qiita Article 1',
        article_url: "https://qiita.com/#{user.qiita_username}/1",
        likes_count: 10,
        is_postable: false
      )

      zenn_article = Article.find_by(source_platform: 'zenn', external_id: 'zenn_1')
      expect(zenn_article).to have_attributes(
        title: 'Zenn Article 1',
        article_url: "https://zenn.dev/#{user.zenn_username}/1",
        likes_count: 15,
        is_postable: false
      )
    end
  end
end

RSpec.describe PlatformArticleFetcher do
  let(:user) { create(:user) }
  let(:qiita_fetcher) { described_class.new(user, 'qiita', 1) }
  let(:zenn_fetcher) { described_class.new(user, 'zenn', 1) }

  describe '#fetch_articles' do
    context 'when fetching Qiita articles' do
      before { stub_qiita_api(user.qiita_username, 'qiita_1', 'qiita_2') }

      it 'saves new articles' do
        expect { qiita_fetcher.fetch_articles }.to change { Article.count }.by(2)
      end

      it 'updates existing articles' do
        existing_article = create(:article, user:, source_platform: 'qiita', external_id: 'qiita_1', title: 'Old Title')
        qiita_fetcher.fetch_articles
        expect(existing_article.reload.title).to eq('Qiita Article 1')
      end
    end

    context 'when fetching Zenn articles' do
      before { stub_zenn_api(user.zenn_username, 'zenn_1', 'zenn_2') }

      it 'saves new articles' do
        expect { zenn_fetcher.fetch_articles }.to change { Article.count }.by(2)
      end

      it 'updates existing articles' do
        existing_article = create(:article, user:, source_platform: 'zenn', external_id: 'zenn_1', title: 'Old Title')
        zenn_fetcher.fetch_articles
        expect(existing_article.reload.title).to eq('Zenn Article 1')
      end
    end
  end
end
