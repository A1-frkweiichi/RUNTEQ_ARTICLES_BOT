require 'rails_helper'

RSpec.describe SendGmailJob, type: :job do
  describe '#perform' do
    let(:gmail_service) { instance_double(GmailService) }
    let(:article_scope) { double('Article scope') }
    let(:qiita_scope) { double('Qiita scope') }
    let(:zenn_scope) { double('Zenn scope') }

    before do
      allow(GmailService).to receive(:new).and_return(gmail_service)
      allow(gmail_service).to receive(:send_email)

      allow(User).to receive(:count).and_return(3)
      allow(Article).to receive(:count).and_return(8)

      allow(Article).to receive(:where).with(is_postable: true, is_active: true).and_return(article_scope)
      allow(article_scope).to receive(:count).and_return(5)
      allow(article_scope).to receive(:qiita).and_return(qiita_scope)
      allow(article_scope).to receive(:zenn).and_return(zenn_scope)
      allow(qiita_scope).to receive(:count).and_return(2)
      allow(zenn_scope).to receive(:count).and_return(1)

      allow_any_instance_of(SendGmailJob).to receive(:generate_post_count_stats).and_return("0回投稿済み: 5")

      allow(User).to receive(:pluck).with(:qiita_username).and_return(%w[qiita_user1 qiita_user2])
      allow(User).to receive(:pluck).with(:zenn_username).and_return(['zenn_user1'])
    end

    it 'sends an email' do
      expect(gmail_service).to receive(:send_email)

      described_class.perform_now
    end
  end
end
