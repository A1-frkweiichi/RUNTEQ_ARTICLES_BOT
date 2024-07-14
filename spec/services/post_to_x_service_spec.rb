require 'rails_helper'

RSpec.describe PostToXService, type: :service do
  let(:article) { create(:article, is_postable: true) }
  let(:x_client) { instance_double(X::Client) }
  let(:post_response) { { "data" => { "id" => "12345" } } }
  let(:service) { described_class.new }

  before do
    allow(Article).to receive(:random_postable_article).and_return(article)
    allow(X::Client).to receive(:new).and_return(x_client)
    allow(x_client).to receive(:post).and_return(post_response)
    allow(File).to receive(:read).and_return("Template content")
  end

  describe '#initialize' do
    context 'when there are no postable articles' do
      before do
        allow(Article).to receive(:random_postable_article).and_return(nil)
      end

      it 'raises an error' do
        expect { described_class.new }.to raise_error('No postable articles found')
      end
    end
  end

  describe '#call' do
    context 'when article is postable' do
      it 'creates a new post' do
        expect { service.call }.to change(Post, :count).by(1)
      end

      it 'posts to X and updates the post status to success' do
        service.call
        expect(Post.last.status).to eq('success')
      end

      it 'increments the post_count of the article' do
        expect { service.call }.to change { article.reload.post_count }.by(1)
      end
    end

    context 'when an error occurs' do
      before do
        allow(x_client).to receive(:post).and_raise(StandardError.new('Error'))
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error and updates the post status to failed' do
        service.call
        expect(Post.last.status).to eq('failed')
        expect(Rails.logger).to have_received(:error).with('Failed to post to X: Error')
      end
    end
  end
end
