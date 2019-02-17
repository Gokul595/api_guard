require 'dummy/spec/rails_helper'

describe 'Change password - User', type: :request do
  describe 'patch #create' do
    context 'with invalid params' do
      it 'should return 401 - missing access token' do
        user = create(:user)
        patch '/users/passwords'

        expect(response).to have_http_status(401)
        expect(response_errors).to include('Access token is missing in the request')
      end

      it 'should return 401 - invalid access token' do
        user = create(:user)
        patch '/users/passwords', headers: { 'Authorization': 'Bearer 123213' }

        expect(response).to have_http_status(401)
        expect(response_errors).to include('Invalid access token')
      end

      it 'should return 401 - expired access token' do
        user = create(:user)
        expired_access_token = access_token_for_resource(user, 'user', true)[0]

        patch '/users/passwords', headers: { 'Authorization': "Bearer #{expired_access_token}" }

        expect(response).to have_http_status(401)
        expect(response_errors).to include('Access token expired')
      end

      it 'should return 422 - invalid password confirmation' do
        user = create(:user)
        access_token, refresh_token = access_token_for_resource(user, 'user')

        patch '/users/passwords',
              params: { user: { password: 'api-pass', password_confirmation: 'api-pppp' } },
              headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': refresh_token }

        expect(response).to have_http_status(422)
        expect(response_errors).to include("Password confirmation doesn't match Password")
      end
    end

    context 'with valid params' do
      it 'should change password' do
        user = create(:user)
        access_token, refresh_token = access_token_for_resource(user, 'user')

        patch '/users/passwords',
              params: { user: { password: 'api-pass', password_confirmation: 'api-pass' } },
              headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': refresh_token }

        expect(response).to have_http_status(200)
        expect(response.headers['Access-Token']).to be_present
        expect(response.headers['Expire-At']).to be_present
        expect(response.headers['Refresh-Token']).to be_present
      end

      it 'should set token_issued_at to current time - invalidate old tokens is enabled' do
        user = create(:user)
        access_token, refresh_token = access_token_for_resource(user, 'user')

        patch '/users/passwords',
              params: { user: { password: 'api-pass', password_confirmation: 'api-pass' } },
              headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': refresh_token }

        expect(response).to have_http_status(200)
        expect(user.token_issued_at.to_i).not_to eq(user.reload.token_issued_at.to_i)
      end

      it 'should not set token_issued_at to current time - invalidate old tokens is disabled' do
        ApiGuard.invalidate_old_tokens_on_password_change = false

        user = create(:user)
        access_token, refresh_token = access_token_for_resource(user, 'user')

        patch '/users/passwords',
              params: { user: { password: 'api-pass', password_confirmation: 'api-pass' } },
              headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': refresh_token }

        expect(response).to have_http_status(200)
        expect(user.token_issued_at.to_i).to eq(user.reload.token_issued_at.to_i)

        ApiGuard.invalidate_old_tokens_on_password_change = false
      end

      it 'should delete old refresh tokens and must have only the new refresh token' do
        user = create(:user)
        access_token, refresh_token = access_token_for_resource(user, 'user')

        patch '/users/passwords',
              params: { user: { password: 'api-pass', password_confirmation: 'api-pass' } },
              headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': refresh_token }

        expect(response).to have_http_status(200)
        expect(user.refresh_tokens.count).to eq(1)
      end
    end
  end
end
