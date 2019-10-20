# frozen_string_literal: true

require 'dummy/spec/rails_helper'
include ApiGuard::JwtAuth::JsonWebToken

describe 'Refresh token - User', type: :request do
  before :all do
    I18n.locale = :en_1
  end

  after :all do
    I18n.locale = :en
  end

  describe 'POST #create' do
    context 'with invalid params' do
      it 'should return 401 - missing access token' do
        create(:user)
        post '/users/tokens'

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Access token is missing')
      end

      it 'should return 401 - invalid access token' do
        create(:user)
        post '/users/tokens', headers: { 'Authorization': 'Bearer 123213' }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Invalid token')
      end

      it 'should return 401 - missing refresh token' do
        user = create(:user)
        access_token = jwt_and_refresh_token(user, 'user')

        post '/users/tokens', headers: { 'Authorization': "Bearer #{access_token}" }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Refresh token is missing')
      end

      it 'should return 401 - invalid refresh token' do
        user = create(:user)
        access_token = jwt_and_refresh_token(user, 'user')[0]

        post '/users/tokens', headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': '12312' }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Refresh token invalid')
      end
    end

    context 'with valid params' do
      it 'should generate new access token - valid access token and refresh token' do
        user = create(:user)
        access_token, refresh_token = jwt_and_refresh_token(user, 'user')

        post '/users/tokens', headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': refresh_token }

        expect(response).to have_http_status(200)
        expect(response_message).to eq('Token refreshed')

        expect(response.headers['Access-Token']).to be_present
        expect(response.headers['Expire-At']).to be_present
        expect(response.headers['Refresh-Token']).to be_present
      end
    end
  end
end
