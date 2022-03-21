# frozen_string_literal: true

require 'dummy/spec/rails_helper'

describe 'Refresh token - Customer', type: :request do
  describe 'POST #create' do
    context 'with invalid params' do
      it 'should return 401 - missing access token' do
        create(:user)
        post '/customers/tokens'

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Access token is missing in the request')
      end

      it 'should return 401 - invalid access token' do
        create(:user)
        post '/customers/tokens', headers: { 'Authorization': 'Bearer 123213' }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Invalid access token')
      end

      it 'should return 401 - missing refresh token' do
        customer = create(:user)
        access_token = jwt_and_refresh_token(customer, 'user')

        post '/customers/tokens', headers: { 'Authorization': "Bearer #{access_token}" }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Refresh token is missing in the request')
      end

      it 'should return 401 - invalid refresh token' do
        customer = create(:user)
        access_token = jwt_and_refresh_token(customer, 'user')[0]

        post '/customers/tokens', headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': '12312' }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Invalid refresh token')
      end

      it 'should return 401 - expired refresh token' do
        customer = create(:user)
        access_token, refresh_token = jwt_and_refresh_token(customer, 'user', false, true)

        post '/customers/tokens', headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': refresh_token }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Invalid refresh token')
      end
    end

    context 'with valid params' do
      it 'should generate new access token - valid access token and refresh token' do
        customer = create(:user)
        access_token, refresh_token = jwt_and_refresh_token(customer, 'user')

        post '/customers/tokens', headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': refresh_token }

        expect(response).to have_http_status(200)
        expect(response.headers['Access-Token']).to be_present
        expect(response.headers['Expire-At']).to be_present
        expect(response.headers['Refresh-Token']).to be_present
      end
      
      it 'should generate new access token - valid access token and refresh token with no expire_at' do
        customer = create(:user)
        access_token, refresh_token = jwt_and_refresh_token(customer, 'user')
        
        # previous versions did not have an expire_at field. those tokens should still be valid
        RefreshToken.find_by_token(refresh_token).update_attributes(expire_at: nil)

        post '/customers/tokens', headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': refresh_token }

        expect(response).to have_http_status(200)
        expect(response.headers['Access-Token']).to be_present
        expect(response.headers['Expire-At']).to be_present
        expect(response.headers['Refresh-Token']).to be_present
      end

      it 'should generate new access token - expired access token and valid refresh token' do
        customer = create(:user)
        access_token, refresh_token = jwt_and_refresh_token(customer, 'user', true)

        post '/customers/tokens', headers: { 'Authorization': "Bearer #{access_token}", 'Refresh-Token': refresh_token }

        expect(response).to have_http_status(200)
        expect(response.headers['Access-Token']).to be_present
        expect(response.headers['Expire-At']).to be_present
        expect(response.headers['Refresh-Token']).to be_present
      end
    end
    
    
  end
end
