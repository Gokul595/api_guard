# frozen_string_literal: true

require 'dummy/spec/rails_helper'

describe 'Authentication - Customer', type: :request do
  describe 'POST #create' do
    context 'with invalid params' do
      it 'should return 422 - invalid login credentials' do
        create(:user)
        post '/customers/sign_in', params: attributes_for(:user).merge(password: 'paas')

        expect(response).to have_http_status(422)
        expect(response_errors).to eq('Invalid login credentials')
      end
    end

    context 'with valid params' do
      it 'should login customer - valid login credentials' do
        create(:user)
        post '/customers/sign_in', params: attributes_for(:user)

        expect(response).to have_http_status(200)
        expect(response.headers['Access-Token']).to be_present
        expect(response.headers['Expire-At']).to be_present
        expect(response.headers['Refresh-Token']).to be_present
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'with invalid params' do
      it 'should return 401 - missing access token' do
        create(:user)
        delete '/customers/sign_out'

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Access token is missing in the request')
      end

      it 'should return 401 - invalid access token' do
        create(:user)
        delete '/customers/sign_out', headers: { 'Authorization': 'Bearer 1232143' }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Invalid access token')
      end

      it 'should return 401 - expired access token' do
        customer = create(:user)
        expired_access_token = jwt_and_refresh_token(customer, 'user', true)[0]

        delete '/customers/sign_out', headers: { 'Authorization': "Bearer #{expired_access_token}" }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Access token expired')
      end
    end

    context 'with valid params' do
      it 'should logout customer - valid access token' do
        customer = create(:user)
        access_token = jwt_and_refresh_token(customer, 'user')[0]

        delete '/customers/sign_out', headers: { 'Authorization': "Bearer #{access_token}" }

        expect(response).to have_http_status(200)
      end

      it 'should revoke access token from future use' do
        customer = create(:user)
        access_token = jwt_and_refresh_token(customer, 'user')[0]

        expect do
          delete '/customers/sign_out', headers: { 'Authorization': "Bearer #{access_token}" }
        end.to change(customer.revoked_tokens, :count).by(1)
      end
    end
  end
end
