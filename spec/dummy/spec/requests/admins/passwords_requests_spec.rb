require 'dummy/spec/rails_helper'

describe 'Change password - Admin', type: :request do
  describe 'patch #create' do
    context 'with invalid params' do
      it 'should return 401 - missing access token' do
        patch '/admins/passwords'

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Access token is missing in the request')
      end

      it 'should return 401 - invalid access token' do
        patch '/admins/passwords', headers: { 'Authorization': 'Bearer 123213' }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Invalid access token')
      end

      it 'should return 401 - expired access token' do
        admin = create(:admin)
        expired_access_token = jwt_and_refresh_token(admin, 'admin', true)[0]

        patch '/admins/passwords', headers: { 'Authorization': "Bearer #{expired_access_token}" }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Access token expired')
      end

      it 'should return 422 - invalid password confirmation' do
        admin = create(:admin)
        access_token, refresh_token = jwt_and_refresh_token(admin, 'admin')

        patch '/admins/passwords',
              params: { password: 'api-pass', password_confirmation: 'api-pppp' },
              headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': refresh_token }

        expect(response).to have_http_status(422)
        expect(response_errors).to eq("Password confirmation doesn't match Password")
      end
    end

    context 'with valid params' do
      it 'should change password' do
        admin = create(:admin)
        access_token, refresh_token = jwt_and_refresh_token(admin, 'admin')

        patch '/admins/passwords',
              params: { password: 'api-pass', password_confirmation: 'api-pass' },
              headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': refresh_token }

        expect(response).to have_http_status(200)
        expect(response.headers['Access-Token']).to be_present
        expect(response.headers['Expire-At']).to be_present
      end
    end
  end
end
