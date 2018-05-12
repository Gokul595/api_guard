require 'dummy/spec/rails_helper'

describe 'Authentication - Admin', type: :request do
  describe 'POST #create' do
    context 'with invalid params' do
      it 'should return 401 - invalid login credentials' do
        @admin = create(:admin)
        post '/admins/sign_in', params: attributes_for(:admin).merge(password: 'paas')

        expect(response).to have_http_status(401)
        expect(response_errors).to include('Invalid admin credentials')
      end
    end

    context 'with valid params' do
      it 'should login admin - valid login credentials' do
        @admin = create(:admin)
        post '/admins/sign_in', params: attributes_for(:admin)

        expect(response).to have_http_status(200)
        expect(response.headers['Access-Token']).to be_present
        expect(response.headers['Expire-At']).to be_present
        # expect(response.headers['Refresh-Token']).to be_present
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'with invalid params' do
      it 'should return 401 - missing access token' do
        @admin = create(:admin)
        delete '/admins/sign_out'

        expect(response).to have_http_status(401)
        expect(response_errors).to include('Access token is missing in the request')
      end

      it 'should return 401 - invalid access token' do
        @admin = create(:admin)
        delete '/admins/sign_out', headers: {'Authorization' => "Bearer 1232143"}

        expect(response).to have_http_status(401)
        expect(response_errors).to include('Invalid access token')
      end

      it 'should return 401 - expired access token' do
        @admin = create(:admin)
        expired_access_token = access_token_for_resource(@admin, 'admin', true)

        delete '/admins/sign_out', headers: {'Authorization' => "Bearer #{expired_access_token}"}

        expect(response).to have_http_status(401)
        expect(response_errors).to include('Token expired')
      end
    end

    context 'with valid params' do
      it 'should login admin - valid login credentials' do
        @admin = create(:admin)
        access_token = access_token_for_resource(@admin, 'admin')

        delete '/admins/sign_out', headers: {'Authorization' => "Bearer #{access_token}"}

        expect(response).to have_http_status(200)
      end
    end
  end
end