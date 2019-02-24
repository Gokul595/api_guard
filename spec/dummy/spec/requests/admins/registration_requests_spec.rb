require 'dummy/spec/rails_helper'

describe 'Registration - Admin', type: :request do

  describe 'POST #create' do
    context 'with invalid params' do
      it 'should return 422 - email blank' do
        post "/admins/sign_up", params: attributes_for(:admin).except(:email)

        expect(response).to have_http_status(422)
        expect(response_errors).to eq("Email can't be blank")
      end
    end

    context 'with valid params' do
      it 'should create a new admin' do
        expect do
          post "/admins/sign_up", params: attributes_for(:admin)
        end.to change(Admin, :count).by(1)

        expect(response).to have_http_status(200)
        expect(response_message).to eq('Signed up successfully')
      end

      it 'should respond access token and refresh token in response headers' do
        post "/admins/sign_up", params: attributes_for(:admin)

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
        admin = create(:admin)
        delete '/admins/delete'

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Access token is missing in the request')
      end

      it 'should return 401 - invalid access token' do
        admin = create(:admin)
        delete '/admins/delete', headers: { 'Authorization': 'Bearer 123213' }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Invalid access token')
      end

      it 'should return 401 - expired access token' do
        admin = create(:admin)
        expired_access_token = jwt_and_refresh_token(admin, 'admin', true)[0]

        delete '/admins/delete', headers: { 'Authorization': "Bearer #{expired_access_token}" }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Access token expired')
      end
    end

    context 'with valid params' do
      it 'should return 200 - successfully deleted' do
        admin = create(:admin)
        access_token = jwt_and_refresh_token(admin, 'admin')[0]

        delete '/admins/delete', headers: { 'Authorization': "Bearer #{access_token}" }

        expect(response).to have_http_status(200)
        expect(parsed_response['message']).to eq('Account deleted successfully')
      end
    end
  end
end
