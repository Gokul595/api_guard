require 'dummy/spec/rails_helper'

describe 'Authentication - User', type: :request do
  before :all do
    I18n.locale = :en_1
  end

  after :all do
    I18n.locale = :en
  end

  describe 'POST #create' do
    context 'with invalid params' do
      it 'should return 422 - invalid login credentials' do
        create(:user)
        post '/users/sign_in', params: attributes_for(:user).merge(password: 'paas')

        expect(response).to have_http_status(422)
        expect(response_errors).to eq('Invalid credentials')
      end

      it 'should return 422 - invalid login credentials translated' do
        create(:user)
        post '/users/sign_in', params: attributes_for(:user).merge(password: 'paas')

        expect(response).to have_http_status(422)
        expect(response_errors).to eq('Invalid credentials')
      end
    end

    context 'with valid params' do
      it 'should login user - valid login credentials' do
        create(:user)
        post '/users/sign_in', params: attributes_for(:user)

        expect(response).to have_http_status(200)
        expect(response_message).to eq('Signed in')

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
        delete '/users/sign_out'

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Access token is missing')
      end

      it 'should return 401 - invalid access token' do
        create(:user)
        delete '/users/sign_out', headers: {'Authorization': "Bearer 1232143"}

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Invalid token')
      end

      it 'should return 401 - expired access token' do
        user = create(:user)
        expired_access_token = jwt_and_refresh_token(user, 'user', true)[0]

        delete '/users/sign_out', headers: {'Authorization': "Bearer #{expired_access_token}"}

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Token expired')
      end
    end

    context 'with valid params' do
      it 'should logout user - valid access token' do
        user = create(:user)
        access_token = jwt_and_refresh_token(user, 'user')[0]

        delete '/users/sign_out', headers: {'Authorization': "Bearer #{access_token}"}

        expect(response).to have_http_status(200)
        expect(response_message).to eq('Signed out')
      end
    end
  end
end
