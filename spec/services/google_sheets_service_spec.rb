require 'rails_helper'
require 'googleauth'
require 'google/apis/sheets_v4'

RSpec.describe GoogleSheetsService, type: :service do
  let(:params) do
    RecordPostParams.new(
      1,
      'Test Title',
      'http://test.com',
      'test_user',
      '#Test',
      Time.now
    )
  end

  before do
    allow(File).to receive(:exist?).and_return(false)
    allow(File).to receive(:exist?).with(ENV.fetch('GOOGLE_APPLICATION_CREDENTIALS', nil)).and_return(true)
    allow(File).to receive(:read).with(ENV.fetch('GOOGLE_APPLICATION_CREDENTIALS', nil)).and_return('{"type": "service_account"}')
    allow(Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_return(double('credentials', apply!: true))
  end

  describe '#initialize' do
    it 'raises error if credentials file is missing' do
      allow(File).to receive(:exist?).with(ENV.fetch('GOOGLE_APPLICATION_CREDENTIALS', nil)).and_return(false)
      expect { GoogleSheetsService.new }.to raise_error(RuntimeError, "Google credentials file not found: #{ENV.fetch('GOOGLE_APPLICATION_CREDENTIALS', nil)}")
    end

    it 'raises error if credentials file cannot be parsed' do
      allow(File).to receive(:read).with(ENV.fetch('GOOGLE_APPLICATION_CREDENTIALS', nil)).and_return('invalid json')
      allow(Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_raise(JSON::ParserError)
      expect { GoogleSheetsService.new }.to raise_error(JSON::ParserError)
    end
  end

  describe '#record_post' do
    let(:google_sheets_service) { GoogleSheetsService.new }

    before do
      allow(google_sheets_service).to receive(:japanese_day_of_week).and_return('日')

      stub_request(:post, "https://www.googleapis.com/oauth2/v4/token")
        .to_return(status: 200, body: "", headers: {})

      stub_request(:post, %r{https://sheets.googleapis.com/v4/spreadsheets/.*/values/.*:append\?valueInputOption=RAW})
        .to_return(status: 200, body: '{"spreadsheetId": "1cZcT20225k7UmuTgb9gmkGHWvq0dOXs7ApoiadrkQy8", "updates": {"updatedRows": 1}}', headers: {})
    end

    it 'records post to Google Sheets' do
      expect_any_instance_of(Google::Apis::SheetsV4::SheetsService).to receive(:append_spreadsheet_value).with(
        GoogleSheetsService::SPREADSHEET_ID,
        GoogleSheetsService::RANGE,
        kind_of(Google::Apis::SheetsV4::ValueRange),
        value_input_option: 'RAW'
      ).and_call_original
      google_sheets_service.record_post(params)
    end

    it 'raises error if Google Sheets API fails' do
      allow_any_instance_of(Google::Apis::SheetsV4::SheetsService).to receive(:append_spreadsheet_value).and_raise(Google::Apis::Error.new('API error'))
      expect { google_sheets_service.record_post(params) }.to raise_error(Google::Apis::Error, 'API error')
    end

    it 'logs the correct information when recording post' do
      allow(Rails.logger).to receive(:info).and_call_original
      expect(Rails.logger).to receive(:info).with("Recording post to Google Sheets with params: #{params.inspect}")
      google_sheets_service.record_post(params)
    end
  end
end
