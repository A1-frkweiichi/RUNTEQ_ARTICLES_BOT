require 'googleauth'
require 'google/apis/sheets_v4'

class GoogleSheetsService
  SPREADSHEET_ID = '1cZcT20225k7UmuTgb9gmkGHWvq0dOXs7ApoiadrkQy8'.freeze
  RANGE = 'Sheet1!A1'.freeze

  def initialize
    scope = Google::Apis::SheetsV4::AUTH_SPREADSHEETS
    @service = Google::Apis::SheetsV4::SheetsService.new
    @service.client_options.application_name = 'Rails Google Sheets'
    @service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(ENV.fetch('GOOGLE_APPLICATION_CREDENTIALS', nil)),
      scope:
    )
  end

  def write_hello_ruby
    values = [
      ['Hello Ruby']
    ]
    value_range_object = Google::Apis::SheetsV4::ValueRange.new(values:)
    @service.update_spreadsheet_value(SPREADSHEET_ID, RANGE, value_range_object, value_input_option: 'RAW')
  rescue Google::Apis::ClientError => e
    puts "Error: #{e.message}"
    puts "Error details: #{e.response_body}"
  end
end
