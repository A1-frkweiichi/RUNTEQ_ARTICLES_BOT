# require 'rails_helper'
# require 'sidekiq/testing'

# RSpec.describe ScheduleNationalHolidayJobs, type: :service do
#   before do
#     Sidekiq::Testing.fake!
#     ActiveJob::Base.queue_adapter = :test
#   end

#   it 'schedules the jobs only once' do
#     ScheduleNationalHolidayJobs.schedule_jobs

#     expect(PostToXJob).to have_been_enqueued.exactly(5).times

#     expect do
#       ScheduleNationalHolidayJobs.schedule_jobs
#     end.not_to(change { Sidekiq::ScheduledSet.new.size })
#   end
# end
