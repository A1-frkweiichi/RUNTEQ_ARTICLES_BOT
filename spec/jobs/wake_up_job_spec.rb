require 'rails_helper'

RSpec.describe WakeUpJob, type: :job do
  include ActiveJob::TestHelper

  before do
    ActiveJob::Base.queue_adapter = :test
    allow(Rails.logger).to receive(:info)
  end

  describe '#perform' do
    it 'queues the job' do
      expect { WakeUpJob.perform_later }.to have_enqueued_job(WakeUpJob).on_queue('default')
    end

    it 'logs success message' do
      perform_enqueued_jobs { WakeUpJob.perform_later }
      expect(Rails.logger).to have_received(:info).with("Success: Wake Up Worker Dyno.")
    end
  end
end
