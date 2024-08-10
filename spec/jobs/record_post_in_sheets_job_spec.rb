require 'rails_helper'
require_relative '../../app/models/concerns/record_post_params'

RSpec.describe RecordPostInSheetsJob, type: :job do
  let(:post) { double('Post', id: 1, created_at: Time.now) }
  let(:article) { double('Article', title: 'Test Title', article_url: 'http://test.com', user: double('User', x_username: 'test_user'), source_platform_hashtag: '#Test') }
  let(:params) { RecordPostParams.new(post.id, article.title, article.article_url, article.user.x_username, article.source_platform_hashtag, post.created_at) }
  let(:google_sheets_service) { instance_double(GoogleSheetsService) }

  before do
    allow(GoogleSheetsService).to receive(:new).and_return(google_sheets_service)
    allow(google_sheets_service).to receive(:record_post).and_return(true)

    stub_request(:post, "https://www.googleapis.com/oauth2/v4/token")
      .to_return(status: 200, body: "", headers: {})

    stub_request(:post, %r{https://sheets.googleapis.com/v4/spreadsheets/.*/values/.*:append\?valueInputOption=RAW})
      .to_return(status: 200, body: "", headers: {})
  end

  it 'records post in sheets' do
    expect(google_sheets_service).to receive(:record_post).with(params)
    RecordPostInSheetsJob.perform_now(post, article)
  end
end
