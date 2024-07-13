require 'rails_helper'
require 'active_support/testing/time_helpers'

RSpec.describe PostToXHolidayJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

  let(:service) { instance_double(PostToXService) }

  before do
    allow(PostToXService).to receive(:new).and_return(service)
  end

  it 'calls PostToXService on holiday' do
    holiday_date = Date.new(2024, 7, 15)
    allow(HolidayJp).to receive(:holiday?).with(holiday_date).and_return(true)

    travel_to holiday_date do
      expect(service).to receive(:call)
      PostToXHolidayJob.perform_now
    end
  end
end
