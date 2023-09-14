# frozen_string_literal: true

require 'dummy/spec/rails_helper'

describe 'Refresh token - User', type: :request do
  include ApiGuard::JwtAuth::JsonWebToken

  describe 'POST #create' do
    context 'with invalid params' do
      it 'should return 401 - missing access token' do
        create(:user)
        post '/users/tokens'

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Access token is missing in the request')
      end

      it 'should return 401 - invalid access token' do
        create(:user)
        post '/users/tokens', headers: { 'Authorization': 'Bearer 123213' }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Invalid access token')
      end

      it 'should return 401 - missing refresh token' do
        user = create(:user)
        access_token = jwt_and_refresh_token(user, 'user')

        post '/users/tokens', headers: { 'Authorization': "Bearer #{access_token}" }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Refresh token is missing in the request')
      end

      it 'should return 401 - invalid refresh token' do
        user = create(:user)
        access_token = jwt_and_refresh_token(user, 'user')[0]

        post '/users/tokens', headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': '12312' }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Invalid refresh token')
      end
    end

    context 'with valid params' do
      it 'should generate new access token - valid access token and refresh token' do
        user = create(:user)
        access_token, refresh_token = jwt_and_refresh_token(user, 'user')

        post '/users/tokens', headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': refresh_token }

        expect(response).to have_http_status(200)
        expect(response.headers['Access-Token']).to be_present
        expect(response.headers['Expire-At']).to be_present
        expect(response.headers['Refresh-Token']).to be_present
      end

      it 'should generate new access token - expired access token and valid refresh token' do
        user = create(:user)
        expired_access_token, refresh_token = jwt_and_refresh_token(user, 'user', true)

        post '/users/tokens', headers: {
          'Authorization': "Bearer #{expired_access_token}", 'Refresh-Token': refresh_token
        }

        expect(response).to have_http_status(200)
        expect(response.headers['Access-Token']).to be_present
        expect(response.headers['Expire-At']).to be_present
        expect(response.headers['Refresh-Token']).to be_present
      end

      it 'should delete refresh token received in request' do
        user = create(:user)
        expired_access_token, refresh_token = jwt_and_refresh_token(user, 'user', true)

        post '/users/tokens', headers: {
          'Authorization': "Bearer #{expired_access_token}", 'Refresh-Token': refresh_token
        }

        expect(response).to have_http_status(200)
        expect(response.headers['Access-Token']).to be_present
        expect(response.headers['Expire-At']).to be_present
        expect(response.headers['Refresh-Token']).to be_present

        expect(user.refresh_tokens.find_by(token: refresh_token)).to be_nil
      end

      it 'should revoke JWT access token after refreshing' do
        user = create(:user)
        access_token, refresh_token = jwt_and_refresh_token(user, 'user')

        ApiGuard.revoke_token_after_refreshing = true

        expect do
          post '/users/tokens', headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': refresh_token }
        end.to change(user.revoked_tokens, :count).by(1)

        ApiGuard.revoke_token_after_refreshing = false

        expect(response).to have_http_status(200)
        expect(response.headers['Access-Token']).to be_present
        expect(response.headers['Expire-At']).to be_present
        expect(response.headers['Refresh-Token']).to be_present
      end

      it 'should not revoke JWT access token after refreshing' do
        user = create(:user)
        access_token, refresh_token = jwt_and_refresh_token(user, 'user')

        expect do
          post '/users/tokens', headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': refresh_token }
        end.to change(user.revoked_tokens, :count).by(0)

        expect(response).to have_http_status(200)
        expect(response.headers['Access-Token']).to be_present
        expect(response.headers['Expire-At']).to be_present
        expect(response.headers['Refresh-Token']).to be_present
      end
    end
  end
end
