module ApiStubHelpers
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
