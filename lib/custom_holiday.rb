module CustomHoliday
  def self.holiday?(date)
    custom_holiday = [
      Date.new(2024, 8, 13),
      Date.new(2024, 8, 14),
      Date.new(2024, 8, 15),
      Date.new(2024, 8, 16)
    ]
    custom_holiday.include?(date)
  end
end
