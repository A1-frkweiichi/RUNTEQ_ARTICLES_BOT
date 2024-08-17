require 'rails_helper'

RSpec.describe GmailService do
  let(:mock_gmail_service) { instance_double(Google::Apis::GmailV1::GmailService) }
  let(:mock_client_options) { double('client_options') }
  let(:mock_logger) { instance_double(Logger) }

  before do
    allow(ENV).to receive(:fetch).with('GMAIL_CREDENTIALS').and_return('spec/fixtures/files/mock_gmail_client_secret.json')

    allow(Google::Apis::GmailV1::GmailService).to receive(:new).and_return(mock_gmail_service)
    allow(mock_gmail_service).to receive(:client_options).and_return(mock_client_options)
    allow(mock_client_options).to receive(:application_name=)
    allow(mock_gmail_service).to receive(:authorization=)
    allow_any_instance_of(described_class).to receive(:authorize).and_return(double('credentials'))

    allow(Logger).to receive(:new).and_return(mock_logger)
    allow(mock_logger).to receive(:info)
    allow(mock_logger).to receive(:error)
  end

  describe '#send_email' do
    it 'sends an email using the Gmail API' do
      service = described_class.new
      to = 'test@example.com'
      subject = 'Test Subject'
      body = 'Test Body'

      expect(mock_gmail_service).to receive(:send_user_message).with('me', instance_of(Google::Apis::GmailV1::Message))

      service.send_email(to, subject, body)
    end
  end
end
