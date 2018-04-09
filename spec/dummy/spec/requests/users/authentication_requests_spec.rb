require 'dummy/spec/rails_helper'

describe 'Authentication - User', type: :request do
  describe 'POST #create' do
    context 'with invalid params' do
      it 'should return 401 - invalid login credentials' do
        @user = create(:user)
        post '/users/sign_in', params: attributes_for(:user).merge(password: 'paas')

        expect(response).to have_http_status(422)
        expect(response_errors).to include('Invalid login credentials')
      end
    end

    context 'with valid params' do
      it 'should login user - valid login credentials' do
        @user = create(:user)
        post '/users/sign_in', params: attributes_for(:user)

        expect(response).to have_http_status(200)
        expect(response.headers['Access-Token']).not_to eq('')
        expect(response.headers['Refresh-Token']).not_to eq('')
      end
    end
  end
end
