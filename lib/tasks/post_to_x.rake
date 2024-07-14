namespace :x do
  desc "$ rails x:post コマンドでの動作確認"
  task post: :environment do
    jst_today = Time.current.in_time_zone('Asia/Tokyo').to_date
    puts "現在のJST日付: #{jst_today}"

    is_holiday = HolidayJp.holiday?(jst_today)
    puts "祝日判定の結果: #{is_holiday}"

    if is_holiday
      PostToXHolidayJob.perform_now
      puts "祝日（土日除く）の投稿"
    elsif Date.weekday_or_weekend?(jst_today)
      PostToXJob.perform_now
      puts "平日・土日の投稿"
    else
      puts "例外処理"
    end
  end
end

class Date
  def self.weekday_or_weekend?(date)
    result = date.on_weekday? || date.saturday? || date.sunday?
    puts "weekday_or_weekend? の結果: #{result}"
    result
  end

  def self.on_weekday?(date)
    result = !date.saturday? && !date.sunday? && !HolidayJp.holiday?(date)
    puts "on_weekday? の結果: #{result}"
    result
  end
end
