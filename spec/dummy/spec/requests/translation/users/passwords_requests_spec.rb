# frozen_string_literal: true

require 'dummy/spec/rails_helper'

describe 'Change password - User', type: :request do
  before :all do
    I18n.locale = :en_1
  end

  after :all do
    I18n.locale = :en
  end

  describe 'patch #create' do
    context 'with invalid params' do
      it 'should return 401 - missing access token' do
        patch '/users/passwords'

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Access token is missing')
      end

      it 'should return 401 - invalid access token' do
        patch '/users/passwords', headers: { 'Authorization': 'Bearer 123213' }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Invalid token')
      end

      it 'should return 401 - expired access token' do
        user = create(:user)
        expired_access_token = jwt_and_refresh_token(user, 'user', true)[0]

        patch '/users/passwords', headers: { 'Authorization': "Bearer #{expired_access_token}" }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Token expired')
      end

      it 'should return 422 - invalid password confirmation' do
        user = create(:user)
        access_token, refresh_token = jwt_and_refresh_token(user, 'user')

        patch '/users/passwords',
              params: { password: 'api-pass', password_confirmation: 'api-pppp' },
              headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': refresh_token }

        expect(response).to have_http_status(422)
        expect(response_errors).to eq("Password confirmation doesn't match Password")
      end
    end

    context 'with valid params' do
      it 'should change password' do
        user = create(:user)
        access_token, refresh_token = jwt_and_refresh_token(user, 'user')

        patch '/users/passwords',
              params: { user: { password: 'api-pass', password_confirmation: 'api-pass' } },
              headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': refresh_token }

        expect(response).to have_http_status(200)
        expect(response_message).to eq('Password changed')

        expect(response.headers['Access-Token']).to be_present
        expect(response.headers['Expire-At']).to be_present
        expect(response.headers['Refresh-Token']).to be_present
      end
    end
  end
end
