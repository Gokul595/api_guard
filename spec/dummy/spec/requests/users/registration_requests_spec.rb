require 'dummy/spec/rails_helper'

describe 'Registration - User', type: :request do
  describe 'POST #create' do
    context 'with invalid params' do
      it 'should raise exception - missing param' do
        expect {
          post "/users/sign_up"
        }.to raise_error ActionController::ParameterMissing
      end

      it 'should return 422 - email blank' do
        post "/users/sign_up", params: { user: attributes_for(:user).except(:email) }

        expect(response).to have_http_status(422)
        expect(response_errors).to include("Email can't be blank")
      end
    end

    context 'with valid params' do
      it 'should create a new user' do
        expect do
          post "/users/sign_up", params: { user: attributes_for(:user) }
        end.to change(User, :count).by(1)

        expect(response).to have_http_status(200)
        expect(response_message).to eq('Signed up successfully')
      end

      it 'should respond access token and refresh token in response headers' do
        post "/users/sign_up", params: { user: attributes_for(:user) }

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
        delete '/users/delete'

        expect(response).to have_http_status(401)
        expect(response_errors).to include('Access token is missing in the request')
      end

      it 'should return 401 - invalid access token' do
        user = create(:user)
        delete '/users/delete', headers: { 'Authorization': 'Bearer 123213' }

        expect(response).to have_http_status(401)
        expect(response_errors).to include('Invalid access token')
      end

      it 'should return 401 - expired access token' do
        user = create(:user)
        expired_access_token = access_token_for_resource(user, 'user', true)[0]

        delete '/users/delete', headers: { 'Authorization': "Bearer #{expired_access_token}" }

        expect(response).to have_http_status(401)
        expect(response_errors).to include('Access token expired')
      end
    end

    context 'with valid params' do
      it 'should return 200 - successfully deleted' do
        user = create(:user)
        access_token = access_token_for_resource(user, 'user')[0]

        delete '/users/delete', headers: { 'Authorization': "Bearer #{access_token}" }

        expect(response).to have_http_status(200)
        expect(parsed_response['message']).to eq('Account deleted successfully')
      end
    end
  end
end
