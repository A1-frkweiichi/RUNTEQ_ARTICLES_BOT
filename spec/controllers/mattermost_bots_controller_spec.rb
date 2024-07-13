require 'rails_helper'

RSpec.describe MattermostBotsController, type: :controller do
  let(:user) { create(:user, mattermost_id: 'test_user_id') }
  let(:valid_token) { ENV.fetch('MATTERMOST_BOT_TOKEN', nil) }
  let(:invalid_token) { 'invalid_token' }

  describe 'POST #open_dialog' do
    context 'with valid token' do
      before do
        allow(controller).to receive(:verify_mattermost_token).and_return(true)
        allow(User).to receive(:find_by).with(mattermost_id: 'test_user_id').and_return(user)
        response_double = double('response', success?: true, code: 200, body: 'response body')
        allow(controller).to receive(:send_mattermost_request).and_return(response_double)
      end

      it 'renders the success message' do
        post :open_dialog, params: { user_id: user.mattermost_id, trigger_id: 'test_trigger', token: valid_token }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['text']).to eq("【らんてくん おすすめ記事】登録フォームを開きました")
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
    let(:valid_submission) { { 'qiita_username' => 'valid_qiita', 'zenn_username' => 'valid_zenn', 'x_username' => 'valid_x' } }
    let(:invalid_submission) { { 'qiita_username' => 'invalid_qiita', 'zenn_username' => 'invalid_zenn' } }

    before do
      allow(controller).to receive(:qiita_username_exists?).with('valid_qiita').and_return(true)
      allow(controller).to receive(:zenn_username_exists?).with('valid_zenn').and_return(true)
      allow(controller).to receive(:qiita_username_exists?).with('invalid_qiita').and_return(false)
      allow(controller).to receive(:zenn_username_exists?).with('invalid_zenn').and_return(false)
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
    end

    context 'with invalid submission' do
      it 'returns validation errors' do
        post :submit_dialog, params: { user_id: user.mattermost_id, submission: invalid_submission }
        expect(response).to have_http_status(:ok)
        errors = JSON.parse(response.body)['errors']
        expect(errors['qiita_username']).to eq('一致するユーザー名が見つかりません')
        expect(errors['zenn_username']).to eq('一致するユーザー名が見つかりません')
      end
    end
  end
end
