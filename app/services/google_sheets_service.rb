require 'googleauth'
require 'google/apis/sheets_v4'

class GoogleSheetsService
  SPREADSHEET_ID = '1cZcT20225k7UmuTgb9gmkGHWvq0dOXs7ApoiadrkQy8'.freeze
  RANGE = '紹介記事!A2'.freeze

  def initialize
    scope = Google::Apis::SheetsV4::AUTH_SPREADSHEETS
    @service = Google::Apis::SheetsV4::SheetsService.new
    @service.client_options.application_name = 'Rails Google Sheets'
    @service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(ENV.fetch('GOOGLE_APPLICATION_CREDENTIALS', nil)),
      scope:
    )
  end

  def record_post(params)
    x_username_url = params.x_username.present? ? "https://x.com/#{params.x_username}" : ''
    cleaned_hashtag = params.hashtag.sub('#', '').capitalize

    jst_created_at = params.created_at.in_time_zone('Asia/Tokyo')
    formatted_date = jst_created_at.strftime('%Y年%m月%d日')
    japanese_day = japanese_day_of_week(jst_created_at.wday)
    formatted_time = jst_created_at.strftime('%H:%M')

    full_date_time = "#{formatted_date}(#{japanese_day}) #{formatted_time}"

    values = [
      [params.post_id, params.article_title, params.article_url, x_username_url, cleaned_hashtag, full_date_time]
    ]
    value_range_object = Google::Apis::SheetsV4::ValueRange.new(values:)
    @service.append_spreadsheet_value(SPREADSHEET_ID, RANGE, value_range_object, value_input_option: 'RAW')
  end

  private

  def japanese_day_of_week(wday)
    %w[日 月 火 水 木 金 土][wday]
  end
end
