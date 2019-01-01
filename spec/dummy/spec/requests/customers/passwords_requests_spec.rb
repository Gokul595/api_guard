require 'dummy/spec/rails_helper'

describe 'Change password - Customer', type: :request do
  describe 'patch #create' do
    context 'with invalid params' do
      it 'should return 401 - missing access token' do
        @customer = create(:user)
        patch '/customers/passwords'

        expect(response).to have_http_status(401)
        expect(response_errors).to include('Access token is missing in the request')
      end

      it 'should return 401 - invalid access token' do
        @customer = create(:user)
        patch '/customers/passwords', headers: { 'Authorization': 'Bearer 123213' }

        expect(response).to have_http_status(401)
        expect(response_errors).to include('Invalid access token')
      end

      it 'should return 401 - expired access token' do
        @customer = create(:user)
        expired_access_token = access_token_for_resource(@customer, 'user', true)[0]

        patch '/customers/passwords', headers: { 'Authorization': "Bearer #{expired_access_token}" }

        expect(response).to have_http_status(401)
        expect(response_errors).to include('Access token expired')
      end

      it 'should return 422 - invalid password confirmation' do
        @customer = create(:user)
        access_token, refresh_token = access_token_for_resource(@customer, 'user')

        patch '/customers/passwords',
              params: { user: { password: 'api-pass', password_confirmation: 'api-pppp' } },
              headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': refresh_token }

        expect(response).to have_http_status(422)
        expect(response_errors).to include("Password confirmation doesn't match Password")
      end
    end

    context 'with valid params' do
      it 'should change password' do
        @customer = create(:user)
        access_token, refresh_token = access_token_for_resource(@customer, 'user')

        patch '/customers/passwords',
              params: { user: { password: 'api-pass', password_confirmation: 'api-pass' } },
              headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': refresh_token }

        expect(response).to have_http_status(200)
        expect(response.headers['Access-Token']).to be_present
        expect(response.headers['Expire-At']).to be_present
        expect(response.headers['Refresh-Token']).to be_present
      end

      it 'should delete old refresh tokens and must have only the new refresh token' do
        @customer = create(:user)
        access_token, refresh_token = access_token_for_resource(@customer, 'user')

        patch '/customers/passwords',
              params: { user: { password: 'api-pass', password_confirmation: 'api-pass' } },
              headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': refresh_token }

        expect(response).to have_http_status(200)
        expect(@customer.refresh_tokens.count).to eq(1)
      end
    end
  end
end
