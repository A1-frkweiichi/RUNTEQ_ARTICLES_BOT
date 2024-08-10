require 'rails_helper'
require_relative '../../app/models/concerns/record_post_params'

RSpec.describe PostToXJob, type: :job do
  let(:user) { create(:user, x_username: 'test_user') }
  let(:article) { create(:article, title: 'Test Title', article_url: 'http://test.com', user:, source_platform: 'qiita') }
  let(:post) { create(:post, article:, user:) }
  let(:service) { instance_double(PostToXService, call: true, post:, article:) }

  before do
    allow(PostToXService).to receive(:new).and_return(service)
    allow(service).to receive(:call)
  end

  it 'calls PostToXService' do
    expect(service).to receive(:call)
    PostToXJob.perform_now
  end

  it 'queues RecordPostInSheetsJob if post is present' do
    expect(RecordPostInSheetsJob).to receive(:perform_later).with(post, article)
    PostToXJob.perform_now
  end

  it 'does not queue RecordPostInSheetsJob if post is not present' do
    allow(service).to receive(:post).and_return(nil)
    expect(RecordPostInSheetsJob).not_to receive(:perform_later)
    PostToXJob.perform_now
  end
end
