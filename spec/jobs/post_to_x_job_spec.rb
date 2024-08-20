require 'rails_helper'
require 'active_support/testing/time_helpers'

RSpec.describe PostToXJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user, x_username: 'test_user') }
  let(:article) { create(:article, title: 'Test Title', article_url: 'http://test.com', user:, source_platform: 'qiita') }
  let(:post) { create(:post, article:, user:) }
  let(:service) { instance_double(PostToXService, call: true, post:, article:) }

  before do
    allow(PostToXService).to receive(:new).and_return(service)
    allow(service).to receive(:call)

    stub_request(:post, "https://www.googleapis.com/oauth2/v4/token")
      .to_return(status: 200, body: "", headers: {})

    stub_request(:post, %r{https://sheets.googleapis.com/v4/spreadsheets/.*/values/.*:append\?valueInputOption=RAW})
      .to_return(status: 200, body: "", headers: {})
  end

  context 'on a weekday' do
    it 'calls PostToXService' do
      travel_to DateTime.new(2024, 9, 12, 10, 0, 0) do
        expect(service).to receive(:call)
        PostToXJob.perform_now
      end
    end

    it 'queues RecordPostInSheetsJob if post is present' do
      travel_to DateTime.new(2024, 9, 12, 10, 0, 0) do
        expect(RecordPostInSheetsJob).to receive(:perform_later).with(article_id: article.id)
        PostToXJob.perform_now
      end
    end

    it 'does not queue RecordPostInSheetsJob if post is not present' do
      allow(service).to receive(:post).and_return(nil)
      travel_to DateTime.new(2024, 9, 12, 10, 0, 0) do
        expect(RecordPostInSheetsJob).not_to receive(:perform_later)
        PostToXJob.perform_now
      end
    end
  end

  context 'on a weekend' do
    it 'calls PostToXService' do
      travel_to DateTime.new(2024, 9, 14, 3, 0, 0) do
        expect(service).to receive(:call)
        PostToXJob.perform_now
      end
    end

    it 'queues RecordPostInSheetsJob if post is present' do
      travel_to DateTime.new(2024, 9, 14, 3, 0, 0) do
        expect(RecordPostInSheetsJob).to receive(:perform_later).with(article_id: article.id)
        PostToXJob.perform_now
      end
    end

    it 'does not queue RecordPostInSheetsJob if post is not present' do
      allow(service).to receive(:post).and_return(nil)
      travel_to DateTime.new(2024, 9, 14, 3, 0, 0) do
        expect(RecordPostInSheetsJob).not_to receive(:perform_later)
        PostToXJob.perform_now
      end
    end
  end

  context 'on a specified holiday' do
    it 'calls PostToXService' do
      travel_to DateTime.new(2024, 9, 16, 3, 0, 0) do
        expect(service).to receive(:call)
        PostToXJob.perform_now
      end
    end

    it 'queues RecordPostInSheetsJob if post is present' do
      travel_to DateTime.new(2024, 9, 16, 3, 0, 0) do
        expect(RecordPostInSheetsJob).to receive(:perform_later).with(article_id: article.id)
        PostToXJob.perform_now
      end
    end

    it 'does not queue RecordPostInSheetsJob if post is not present' do
      allow(service).to receive(:post).and_return(nil)
      travel_to DateTime.new(2024, 9, 16, 3, 0, 0) do
        expect(RecordPostInSheetsJob).not_to receive(:perform_later)
        PostToXJob.perform_now
      end
    end
  end
end
