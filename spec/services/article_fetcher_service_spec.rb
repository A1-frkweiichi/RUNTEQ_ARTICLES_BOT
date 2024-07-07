# spec/services/article_fetcher_service_spec.rb

RSpec.describe ArticleFetcherService do
  let(:user) { create(:user) }
  let(:service) { described_class.new(user) }

  describe '#fetch_all' do
    before do
      stub_qiita_api(user.qiita_username, 'qiita_1', 'qiita_2')
      stub_zenn_api(user.zenn_username, 'zenn_1', 'zenn_2')
    end

    it 'fetches articles from both platforms' do
      expect { service.fetch_all }.to change { Article.count }.by(4)
    end
  end

  describe '#fetch_articles' do
    context 'when fetching Qiita articles' do
      before { stub_qiita_api(user.qiita_username, 'qiita_1', 'qiita_2') }

      it 'saves new articles' do
        expect { service.send(:fetch_articles, 'qiita') }.to change { Article.count }.by(2)
      end

      it 'updates existing articles' do
        existing_article = create(:article, user:, source_platform: 'qiita', external_id: 'qiita_1', title: 'Old Title')
        service.send(:fetch_articles, 'qiita')
        expect(existing_article.reload.title).to eq('Qiita Article 1')
      end
    end

    context 'when fetching Zenn articles' do
      before { stub_zenn_api(user.zenn_username, 'zenn_1', 'zenn_2') }

      it 'saves new articles' do
        expect { service.send(:fetch_articles, 'zenn') }.to change { Article.count }.by(2)
      end

      it 'updates existing articles' do
        existing_article = create(:article, user:, source_platform: 'zenn', external_id: 'zenn_1', title: 'Old Title')
        service.send(:fetch_articles, 'zenn')
        expect(existing_article.reload.title).to eq('Zenn Article 1')
      end
    end
  end

  def stub_qiita_api(username, id1, id2)
    qiita_response = [
      { 'id' => id1, 'title' => 'Qiita Article 1', 'url' => "https://qiita.com/#{username}/1", 'created_at' => '2023-01-01', 'likes_count' => 10 },
      { 'id' => id2, 'title' => 'Qiita Article 2', 'url' => "https://qiita.com/#{username}/2", 'created_at' => '2023-01-02', 'likes_count' => 20 }
    ]
    stub_request(:get, /qiita.com/).with(query: hash_including({ "page" => "1" }))
                                   .to_return(status: 200, body: qiita_response.to_json, headers: { 'Content-Type' => 'application/json' })
    stub_request(:get, /qiita.com/).with(query: hash_including({ "page" => "2" }))
                                   .to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_zenn_api(username, id1, id2)
    zenn_response = {
      'articles' => [
        { 'id' => id1, 'title' => 'Zenn Article 1', 'path' => "/#{username}/1", 'published_at' => '2023-01-01', 'liked_count' => 15 },
        { 'id' => id2, 'title' => 'Zenn Article 2', 'path' => "/#{username}/2", 'published_at' => '2023-01-02', 'liked_count' => 25 }
      ]
    }
    stub_request(:get, /zenn.dev/).with(query: hash_including({ "page" => "1" }))
                                  .to_return(status: 200, body: zenn_response.to_json, headers: { 'Content-Type' => 'application/json' })
    stub_request(:get, /zenn.dev/).with(query: hash_including({ "page" => "2" }))
                                  .to_return(status: 200, body: { 'articles' => [] }.to_json, headers: { 'Content-Type' => 'application/json' })
  end
end
