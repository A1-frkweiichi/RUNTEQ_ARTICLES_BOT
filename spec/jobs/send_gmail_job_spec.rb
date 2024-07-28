require 'rails_helper'

RSpec.describe SendGmailJob, type: :job do
  describe '#perform' do
    let(:gmail_service) { instance_double(GmailService) }

    before do
      allow(GmailService).to receive(:new).and_return(gmail_service)
      allow(gmail_service).to receive(:send_email)

      allow(User).to receive(:count).and_return(3)

      allow(Article).to receive(:count).and_return(8)
      allow(Article).to receive(:where).with(is_postable: true, is_active: true).and_return(double(count: 5))

      allow_any_instance_of(described_class).to receive(:generate_post_count_stats).and_return("0回: 5")
    end

    it 'sends an email with the correct information' do
      expect(gmail_service).to receive(:send_email).with(
        'qiita.from.runteq@gmail.com',
        '登録状況推移',
        /登録ユーザー数: 3\n登録記事数: 8\n投稿対象記事数: 5\n投稿対象記事数 内訳\n0回: 5/
      )

      described_class.perform_now
    end
  end
end
