require 'rails_helper'
require 'webmock/rspec'

class TestLogger
  attr_accessor :logs

  def initialize
    @logs = { info: [], error: [], debug: [] }
  end

  def info(message)
    @logs[:info] << message
  end

  def error(message)
    @logs[:error] << message
  end

  def debug(message)
    @logs[:debug] << message
  end
end

RSpec.describe RegisterToMattermostController, type: :controller do
  let(:user) { create(:user, mattermost_id: 'test_user_id') }
  let(:valid_token) { ENV.fetch('MATTERMOST_BOT_TOKEN', nil) }
  let(:invalid_token) { 'invalid_token' }
  let(:test_logger) { TestLogger.new }

  before do
    stub_request(:get, %r{https://qiita.com/api/v2/users/valid_qiita})
      .to_return(status: 200, body: '', headers: {})
    stub_request(:get, %r{https://qiita.com/api/v2/users/invalid_qiita})
      .to_return(status: 404, body: '', headers: {})
    stub_request(:get, %r{https://zenn.dev/api/users/valid_zenn})
      .to_return(status: 200, body: '', headers: {})
    stub_request(:get, %r{https://zenn.dev/api/users/invalid_zenn})
      .to_return(status: 404, body: '', headers: {})

    allow(Rails).to receive(:logger).and_return(test_logger)
  end

  describe 'POST #open_dialog' do
    context 'with valid token' do
      before do
        allow(controller).to receive(:verify_mattermost_token).and_return(true)
        allow(User).to receive(:find_by).with(mattermost_id: 'test_user_id').and_return(user)
        response_double = double('response', success?: true, code: 200, body: 'response body')
        allow(MattermostRegistrationService).to receive(:send_mattermost_request).and_return(response_double)
      end

      it 'renders the success message' do
        post :open_dialog, params: { user_id: user.mattermost_id, trigger_id: 'test_trigger', token: valid_token }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['text']).to eq("【らんてくん おすすめ記事】登録フォームを開きました")
      end

      it 'logs the Mattermost response' do
        post :open_dialog, params: { user_id: user.mattermost_id, trigger_id: 'test_trigger', token: valid_token }
        expect(test_logger.logs[:debug]).to include("Mattermost response status: 200")
        expect(test_logger.logs[:debug]).to include("Mattermost response body: response body")
      end
    end

    context 'with invalid token' do
      it 'renders unauthorized error' do
        post :open_dialog, params: { user_id: user.mattermost_id, trigger_id: 'test_trigger', token: invalid_token }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['text']).to eq('Unauthorized: TOKENによるエラー')
      end
    end
  end

  describe 'POST #submit_dialog' do
    let(:valid_submission) { ActionController::Parameters.new({ 'qiita_username' => 'valid_qiita', 'zenn_username' => 'valid_zenn', 'x_username' => 'valid_x' }).permit! }
    let(:invalid_submission) { ActionController::Parameters.new({ 'qiita_username' => 'invalid_qiita', 'zenn_username' => 'invalid_zenn' }).permit! }

    before do
      allow(MattermostUsernamesService).to receive(:sanitize_usernames).and_return(valid_submission)
      allow(MattermostUsernamesService).to receive(:validate_usernames).with(instance_of(ActionController::Parameters)).and_call_original
      allow(MattermostUsernamesService).to receive(:validate_usernames).with(valid_submission).and_return({})
      allow(MattermostUsernamesService).to receive(:validate_usernames).with(invalid_submission).and_return({
                                                                                                              'qiita_username' => '一致するユーザー名が見つかりません',
                                                                                                              'zenn_username' => '一致するユーザー名が見つかりません'
                                                                                                            })
    end

    context 'when submission is cancelled' do
      it 'returns an empty json response' do
        post :submit_dialog, params: { cancelled: true }
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq('{}')
      end
    end

    context 'with valid submission' do
      it 'saves the user and returns success' do
        post :submit_dialog, params: { user_id: user.mattermost_id, submission: valid_submission }
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq('{}')
        user.reload
        expect(user.qiita_username).to eq('valid_qiita')
        expect(user.zenn_username).to eq('valid_zenn')
        expect(user.x_username).to eq('valid_x')
      end

      it 'logs a success message' do
        post :submit_dialog, params: { user_id: user.mattermost_id, submission: valid_submission }
        expect(test_logger.logs[:info]).to include(/登録成功！/)
      end
    end

    context 'with invalid submission' do
      it 'returns validation errors' do
        post :submit_dialog, params: { user_id: user.mattermost_id, submission: invalid_submission }
        expect(response).to have_http_status(:ok)
        errors = JSON.parse(response.body)['errors']
        expect(errors['qiita_username']).to eq('一致するユーザー名が見つかりません')
        expect(errors['zenn_username']).to eq('一致するユーザー名が見つかりません')
      end

      it 'logs validation errors' do
        post :submit_dialog, params: { user_id: user.mattermost_id, submission: invalid_submission }
        expect(test_logger.logs[:error]).to include(/登録失敗👀 Mattermost ID: test_user_id. Validation Errors: qiita_username: 一致するユーザー名が見つかりません, zenn_username: 一致するユーザー名が見つかりません/)
      end
    end
  end
end
