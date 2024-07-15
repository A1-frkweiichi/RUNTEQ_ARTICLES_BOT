require 'rails_helper'

RSpec.describe FetchArticlesJob, type: :job do
  let!(:user1) { create(:user, qiita_username: 'test_qiita1', zenn_username: 'test_zenn1', mattermost_id: 'mattermost1') }
  let!(:user2) { create(:user, qiita_username: 'test_qiita2', zenn_username: 'test_zenn2', mattermost_id: 'mattermost2') }

  it 'calls ArticleFetcherService for specific user' do
    service = instance_double(ArticleFetcherService)
    allow(ArticleFetcherService).to receive(:new).with(user1, anything).and_return(service)
    expect(service).to receive(:fetch_all)
    FetchArticlesJob.perform_now(user1.qiita_username, user1.zenn_username)
  end

  it 'calls ArticleFetcherService for each user' do
    user1_service = instance_double(ArticleFetcherService)
    user2_service = instance_double(ArticleFetcherService)

    allow(ArticleFetcherService).to receive(:new).with(user1, anything).and_return(user1_service)
    allow(ArticleFetcherService).to receive(:new).with(user2, anything).and_return(user2_service)

    expect(user1_service).to receive(:fetch_all)
    expect(user2_service).to receive(:fetch_all)

    FetchArticlesJob.perform_now
  end
end
