require 'rails_helper'
require_relative '../../app/models/concerns/record_post_params'

RSpec.describe RecordPostInSheetsJob, type: :job do
  let(:post) { instance_double('Post', id: 1, created_at: Time.now) }
  let(:user) { instance_double('User', x_username: 'test_user') }
  let(:article) { instance_double('Article', id: 2, title: 'Test Title', article_url: 'http://test.com', user:, source_platform_hashtag: '#Test') }
  let(:params) { RecordPostParams.new(post.id, article.title, article.article_url, article.user.x_username, article.source_platform_hashtag, post.created_at) }
  let(:google_sheets_service) { instance_double(GoogleSheetsService) }

  before do
    allow(Post).to receive(:find_by).with(id: post.id).and_return(post)
    allow(Article).to receive(:find_by).with(id: article.id).and_return(article)
    allow(GoogleSheetsService).to receive(:new).and_return(google_sheets_service)
    allow(google_sheets_service).to receive(:record_post).and_return(true)

    stub_request(:post, "https://www.googleapis.com/oauth2/v4/token")
      .to_return(status: 200, body: "", headers: {})

    stub_request(:post, %r{https://sheets.googleapis.com/v4/spreadsheets/.*/values/.*:append\?valueInputOption=RAW})
      .to_return(status: 200, body: "", headers: {})
  end

  it 'records post in sheets' do
    expect(google_sheets_service).to receive(:record_post).with(params)
    RecordPostInSheetsJob.perform_now(post.id, article.id)
  end
end
