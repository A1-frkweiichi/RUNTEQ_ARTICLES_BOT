module DateHelper
  def self.should_post_today?(date)
    holiday_today?(date) || weekday_or_weekend?(date)
  end

  def self.holiday_today?(date)
    holiday?(date) && !weekend?(date)
  end

  def self.weekday_or_weekend?(date)
    weekday?(date) || weekend?(date)
  end

  def self.weekday?(date)
    !weekend?(date) && !HolidayJp.holiday?(date)
  end

  def self.holiday?(date)
    CustomHoliday.holiday?(date) || HolidayJp.holiday?(date)
  end

  def self.weekend?(date)
    date.saturday? || date.sunday?
  end
end
