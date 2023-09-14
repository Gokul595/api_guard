# frozen_string_literal: true

require 'dummy/spec/rails_helper'

describe 'Authentication - Admin', type: :request do
  describe 'POST #create' do
    context 'with invalid params' do
      it 'should return 401 - invalid login credentials' do
        create(:admin)
        post '/admins/sign_in', params: attributes_for(:admin).merge(password: 'paas')

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Invalid admin credentials')
      end
    end

    context 'with valid params' do
      it 'should login admin - valid login credentials' do
        create(:admin)
        post '/admins/sign_in', params: attributes_for(:admin)

        expect(response).to have_http_status(200)
        expect(response.headers['Access-Token']).to be_present
        expect(response.headers['Expire-At']).to be_present
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'with invalid params' do
      it 'should return 401 - missing access token' do
        create(:admin)
        delete '/admins/sign_out'

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Access token is missing in the request')
      end

      it 'should return 401 - invalid access token' do
        create(:admin)
        delete '/admins/sign_out', headers: { 'Authorization': 'Bearer 1232143' }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Invalid access token')
      end

      it 'should return 401 - expired access token' do
        admin = create(:admin)
        expired_access_token = jwt_and_refresh_token(admin, 'admin', true)[0]

        delete '/admins/sign_out', headers: { 'Authorization': "Bearer #{expired_access_token}" }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Access token expired')
      end
    end

    context 'with valid params' do
      it 'should logout admin - valid access token' do
        admin = create(:admin)
        access_token = jwt_and_refresh_token(admin, 'admin')[0]

        delete '/admins/sign_out', headers: { 'Authorization': "Bearer #{access_token}" }

        expect(response).to have_http_status(200)
      end

      it 'should revoke access token from future use' do
        admin = create(:admin)
        access_token = jwt_and_refresh_token(admin, 'admin')[0]

        expect do
          delete '/admins/sign_out', headers: { 'Authorization': "Bearer #{access_token}" }
        end.to change(admin.revoked_tokens, :count).by(1)
      end
    end
  end
end
