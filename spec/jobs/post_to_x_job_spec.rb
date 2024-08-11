require 'rails_helper'
require 'date_helper'
require 'active_support/testing/time_helpers'
require_relative '../../app/models/concerns/record_post_params'

RSpec.describe PostToXJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user, x_username: 'test_user') }
  let(:article) { create(:article, title: 'Test Title', article_url: 'http://test.com', user:, source_platform: 'qiita') }
  let(:post) { create(:post, article:, user:) }
  let(:service) { instance_double(PostToXService, call: true, post:, article:) }

  before do
    allow(PostToXService).to receive(:new).and_return(service)
    allow(service).to receive(:call)

    stub_request(:post, "https://www.googleapis.com/oauth2/v4/token")
      .to_return(status: 200, body: "", headers: {})

    stub_request(:post, %r{https://sheets.googleapis.com/v4/spreadsheets/.*/values/.*:append\?valueInputOption=RAW})
      .to_return(status: 200, body: "", headers: {})
  end

  it 'calls PostToXService on a holiday' do
    holiday_date = Date.new(2024, 7, 15)
    allow(HolidayJp).to receive(:holiday?).with(holiday_date).and_return(true)

    travel_to holiday_date do
      expect(service).to receive(:call)
      PostToXJob.perform_now
    end
  end

  it 'queues RecordPostInSheetsJob if post is present on a holiday' do
    holiday_date = Date.new(2024, 7, 15)
    allow(HolidayJp).to receive(:holiday?).with(holiday_date).and_return(true)

    travel_to holiday_date do
      expect(RecordPostInSheetsJob).to receive(:perform_later).with(post.id, article.id)
      PostToXJob.perform_now
    end
  end

  it 'does not queue RecordPostInSheetsJob if post is not present on a holiday' do
    allow(service).to receive(:post).and_return(nil)
    holiday_date = Date.new(2024, 7, 15)
    allow(HolidayJp).to receive(:holiday?).with(holiday_date).and_return(true)

    travel_to holiday_date do
      expect(RecordPostInSheetsJob).not_to receive(:perform_later)
      PostToXJob.perform_now
    end
  end

  it 'calls PostToXService on a weekday' do
    weekday_date = Date.new(2024, 7, 16)
    allow(HolidayJp).to receive(:holiday?).with(weekday_date).and_return(false)

    travel_to weekday_date do
      expect(service).to receive(:call)
      PostToXJob.perform_now
    end
  end

  it 'queues RecordPostInSheetsJob if post is present on a weekday' do
    weekday_date = Date.new(2024, 7, 16)
    allow(HolidayJp).to receive(:holiday?).with(weekday_date).and_return(false)

    travel_to weekday_date do
      expect(RecordPostInSheetsJob).to receive(:perform_later).with(post.id, article.id)
      PostToXJob.perform_now
    end
  end

  it 'does not queue RecordPostInSheetsJob if post is not present on a weekday' do
    allow(service).to receive(:post).and_return(nil)
    weekday_date = Date.new(2024, 7, 16)
    allow(HolidayJp).to receive(:holiday?).with(weekday_date).and_return(false)

    travel_to weekday_date do
      expect(RecordPostInSheetsJob).not_to receive(:perform_later)
      PostToXJob.perform_now
    end
  end
end
