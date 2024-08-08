require 'rails_helper'
require 'active_support/testing/time_helpers'
require 'custom_holiday'
require_relative '../../app/models/concerns/record_post_params'

RSpec.describe PostNationalHolidayJob, type: :job do
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
      PostNationalHolidayJob.perform_now
    end
  end

  it 'calls PostToXService on custom holiday' do
    custom_holiday_date = Date.new(2024, 8, 13)

    travel_to custom_holiday_date do
      expect(service).to receive(:call)
      PostNationalHolidayJob.perform_now
    end
  end

  it 'does not call PostToXService on a non-holiday' do
    non_holiday_date = Date.new(2024, 8, 12)
    allow(HolidayJp).to receive(:holiday?).with(non_holiday_date).and_return(false)
    allow(CustomHoliday).to receive(:holiday?).with(non_holiday_date).and_return(false)

    travel_to non_holiday_date do
      expect(service).not_to receive(:call)
      PostNationalHolidayJob.perform_now
    end
  end
end

RSpec.describe CustomHoliday, type: :module do
  it 'recognizes custom holiday dates' do
    custom_holiday_dates = [
      Date.new(2024, 8, 13),
      Date.new(2024, 8, 14),
      Date.new(2024, 8, 15),
      Date.new(2024, 8, 16)
    ]

    custom_holiday_dates.each do |date|
      expect(CustomHoliday.holiday?(date)).to be true
    end
  end

  it 'does not recognize non-custom holiday dates' do
    non_holiday_date = Date.new(2024, 8, 12)
    expect(CustomHoliday.holiday?(non_holiday_date)).to be false
  end
end
