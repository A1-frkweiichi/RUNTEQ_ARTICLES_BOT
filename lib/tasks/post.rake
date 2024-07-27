namespace :post do
  desc "$ rails post:execute  投稿タスク"
  task execute: :environment do
    jst_today = Time.current.in_time_zone('Asia/Tokyo').to_date
    is_holiday = HolidayJp.holiday?(jst_today)

    if is_holiday
      PostHolidayJob.perform_now
    elsif weekday_or_weekend?(jst_today)
      PostJob.perform_now
    else
      puts "例外処理"
    end
  end

  def self.weekday_or_weekend?(date)
    on_weekday?(date) || date.saturday? || date.sunday?
  end

  def self.on_weekday?(date)
    !date.saturday? && !date.sunday? && !HolidayJp.holiday?(date)
  end
end
