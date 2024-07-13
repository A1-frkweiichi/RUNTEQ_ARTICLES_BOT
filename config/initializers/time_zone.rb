class Time
  def self.jst
    now.in_time_zone('Asia/Tokyo')
  end
end

class Date
  def self.jst
    Time.now.in_time_zone('Asia/Tokyo').to_date
  end
end
