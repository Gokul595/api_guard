require 'dummy/spec/rails_helper'

describe 'Registration - Customer(User)', type: :request do
  describe 'POST #create' do
    context 'with valid params' do
      it 'should create a new customer (i.e.) User' do
        expect do
          post "/customers/create", params: { customer: attributes_for(:user) }
        end.to change(User, :count).by(1)

        expect(response).to have_http_status(200)
        expect(response_message).to eq('Signed up successfully')
      end

      it 'should respond access token and refresh token in response headers' do
        post "/customers/create", params: { customer: attributes_for(:user) }

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
        user = create(:user)
        delete '/customers/delete'

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Access token is missing in the request')
      end

      it 'should return 401 - invalid access token' do
        user = create(:user)
        delete '/customers/delete', headers: { 'Authorization': 'Bearer 123213' }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Invalid access token')
      end

      it 'should return 401 - expired access token' do
        user = create(:user)
        expired_access_token = jwt_and_refresh_token(user, 'user', true)[0]

        delete '/customers/delete', headers: { 'Authorization': "Bearer #{expired_access_token}" }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Access token expired')
      end
    end

    context 'with valid params' do
      it 'should return 200 - successfully deleted' do
        user = create(:user)
        access_token = jwt_and_refresh_token(user, 'user')[0]

        delete '/customers/delete', headers: { 'Authorization': "Bearer #{access_token}" }

        expect(response).to have_http_status(200)
        expect(parsed_response['message']).to eq('Customer destroyed successfully')
      end
    end
  end
end
