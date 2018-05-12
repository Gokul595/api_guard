require 'dummy/spec/rails_helper'

describe 'Refresh token - User', type: :request do
  describe 'POST #create' do
    context 'with invalid params' do
      it 'should return 401 - missing access token' do
        @user = create(:user)
        post '/users/tokens'

        expect(response).to have_http_status(401)
        expect(response_errors).to include('Access token is missing in the request')
      end

      it 'should return 401 - invalid access token' do
        @user = create(:user)
        post '/users/tokens', headers: {'Authorization' => 'Bearer 123213'}

        expect(response).to have_http_status(401)
        expect(response_errors).to include('Invalid access token')
      end

      it 'should return 401 - missing refresh token' do
        @user = create(:user)
        access_token = access_token_for_resource(@user, 'user')

        post '/users/tokens', headers: {'Authorization' => "Bearer #{access_token}"}

        expect(response).to have_http_status(401)
        expect(response_errors).to include('Refresh token is missing in the request')
      end

      it 'should return 401 - invalid refresh token' do
        @user = create(:user)
        access_token = access_token_for_resource(@user, 'user')[0]

        post '/users/tokens', headers: {'Authorization' => "Bearer #{access_token}", 'Refresh-Token' => '12312'}

        expect(response).to have_http_status(401)
        expect(response_errors).to include('Invalid refresh token')
      end
    end

    context 'with valid params' do
      it 'should login user - valid access token and refresh token' do
        @user = create(:user)
        access_token, refresh_token = access_token_for_resource(@user, 'user')

        post '/users/tokens', headers: {'Authorization' => "Bearer #{access_token}", 'Refresh-Token' => refresh_token}

        expect(response).to have_http_status(200)
        expect(response.headers['Access-Token']).to be_present
        expect(response.headers['Expire-At']).to be_present
        expect(response.headers['Refresh-Token']).to be_present
      end

      it 'should login user - expired access token and valid refresh token' do
        @user = create(:user)
        access_token, refresh_token = access_token_for_resource(@user, 'user', true)

        post '/users/tokens', headers: {'Authorization' => "Bearer #{access_token}", 'Refresh-Token' => refresh_token}

        expect(response).to have_http_status(200)
        expect(response.headers['Access-Token']).to be_present
        expect(response.headers['Expire-At']).to be_present
        expect(response.headers['Refresh-Token']).to be_present
      end
    end
  end
end
