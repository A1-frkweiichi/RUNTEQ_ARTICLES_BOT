namespace :x do
  desc "$ rake x:post  コマンドでの動作確認"
  task post: :environment do
    if Date.weekday_or_weekend?(Date.today)
      PostToXJob.perform_now
      puts "平日・土日の投稿"
    elsif HolidayJp.holiday?(Date.today)
      PostToXHolidayJob.perform_now
      puts "祝日（土日除く）の投稿"
    else
      puts "例外処理"
    end
  end
end

class Date
  def self.weekday_or_weekend?(date)
    date.on_weekday? || date.saturday? || date.sunday?
  end

  def self.on_weekday?(date)
    !date.saturday? && !date.sunday? && !HolidayJp.holiday?(date)
  end
end
