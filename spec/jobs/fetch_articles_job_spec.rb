require 'rails_helper'

RSpec.describe FetchArticlesJob, type: :job do
  let(:user) { create(:user) }
  let(:service) { instance_double(ArticleFetcherService) }

  before do
    allow(ArticleFetcherService).to receive(:new).and_return(service)
    allow(service).to receive(:fetch_all)
  end

  it 'calls ArticleFetcherService' do
    expect(service).to receive(:fetch_all)
    FetchArticlesJob.perform_now(user.id)
  end
end
