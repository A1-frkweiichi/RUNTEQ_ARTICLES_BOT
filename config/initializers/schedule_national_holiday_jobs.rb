if Rails.env.production? || Rails.env.development?
  scheduled_dates = [
    DateTime.new(2024, 9, 16, 3, 0, 0),
    DateTime.new(2024, 9, 23, 3, 0, 0),
    DateTime.new(2024, 10, 14, 3, 0, 0),
    DateTime.new(2024, 11, 4, 3, 0, 0),
    DateTime.new(2024, 12, 30, 3, 0, 0),
    DateTime.new(2024, 12, 31, 3, 0, 0)
  ]

  scheduled_dates.each do |date|
    PostToXJob.perform_at(date)
  end
end
