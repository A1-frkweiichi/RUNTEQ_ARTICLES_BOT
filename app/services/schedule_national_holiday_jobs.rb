class ScheduleNationalHolidayJobs
  def self.schedule_jobs
    scheduled_dates = [
      DateTime.new(2024, 9, 23, 3, 0, 0),
      DateTime.new(2024, 10, 14, 3, 0, 0),
      DateTime.new(2024, 11, 4, 3, 0, 0),
      DateTime.new(2024, 12, 30, 3, 0, 0),
      DateTime.new(2024, 12, 31, 3, 0, 0)
    ]

    scheduled_dates.each do |date|
      PostToXJob.set(wait_until: date).perform_later unless job_scheduled?(date)
    end
  end

  def self.job_scheduled?(date)
    Sidekiq::ScheduledSet.new.any? { |job| job.klass == 'PostToXJob' && Time.at(job.at) == date }
  end
end
