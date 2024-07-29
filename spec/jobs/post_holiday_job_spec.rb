require 'rails_helper'
require 'active_support/testing/time_helpers'

RSpec.describe PostHolidayJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

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

  it 'calls PostToXService on holiday' do
    holiday_date = Date.new(2024, 7, 15)
    allow(HolidayJp).to receive(:holiday?).with(holiday_date).and_return(true)

    travel_to holiday_date do
      expect(service).to receive(:call)
      PostHolidayJob.perform_now
    end
  end

  # it 'records in sheets' do
  #   expect(service).to receive(:call)
  #   expect(service).to receive(:post).and_return(post)
  #   expect(service).to receive(:article).and_return(article)
  #
  #   expect_any_instance_of(GoogleSheetsService).to receive(:record_post)
  #
  #   PostJob.perform_now
  # end
end
