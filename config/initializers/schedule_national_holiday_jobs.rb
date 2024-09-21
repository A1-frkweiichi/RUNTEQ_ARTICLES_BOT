Rails.application.config.after_initialize do
  ScheduleNationalHolidayJobs.schedule_jobs
end
