require 'rails_helper'

RSpec.describe RecordPostInSheetsJob, type: :job do
  let(:user) { instance_double('User', x_username: 'test_user') }
  let(:article) { instance_double('Article', id: 2, title: 'Test Title', article_url: 'http://test.com', user:, source_platform_hashtag: '#Test') }
  let(:params) { { article_id: article.id } }
  let(:google_sheets_service) { instance_double(GoogleSheetsService) }

  before do
    allow(Article).to receive(:find_by).with(id: article.id).and_return(article)
    allow(GoogleSheetsService).to receive(:new).and_return(google_sheets_service)
    allow(google_sheets_service).to receive(:record_post).and_return(true)

    stub_request(:post, "https://www.googleapis.com/oauth2/v4/token")
      .to_return(status: 200, body: "", headers: {})

    stub_request(:post, %r{https://sheets.googleapis.com/v4/spreadsheets/.*/values/.*:append\?valueInputOption=RAW})
      .to_return(status: 200, body: "", headers: {})
  end

  it 'records post in sheets' do
    expect(google_sheets_service).to receive(:record_post).with(hash_including(article_id: article.id))
    RecordPostInSheetsJob.perform_now(params)
  end
end
