require 'rails_helper'

RSpec.describe PostJob, type: :job do
  let(:service) { instance_double(PostToXService) }
  let(:post) { double('Post', id: 1, created_at: Time.now) }
  let(:article) { double('Article', title: 'Test Title', article_url: 'http://test.com', user: double('User', x_username: 'test_user'), source_platform_hashtag: '#Test') }

  before do
    allow(PostToXService).to receive(:new).and_return(service)
    allow(service).to receive(:call)
    allow(service).to receive(:post).and_return(post)
    allow(service).to receive(:article).and_return(article)

    stub_request(:post, "https://www.googleapis.com/oauth2/v4/token")
      .to_return(status: 200, body: "", headers: {})

    stub_request(:post, %r{https://sheets.googleapis.com/v4/spreadsheets/.*/values/.*:append\?valueInputOption=RAW})
      .to_return(status: 200, body: "", headers: {})

    allow_any_instance_of(GoogleSheetsService).to receive(:record_post).and_return(true)
  end

  it 'calls PostToXService' do
    expect(service).to receive(:call)
    PostJob.perform_now
  end

  it 'records in sheets' do
    expect(service).to receive(:call)
    expect(service).to receive(:post).and_return(post)
    expect(service).to receive(:article).and_return(article)

    expect_any_instance_of(GoogleSheetsService).to receive(:record_post)

    PostJob.perform_now
  end
end
