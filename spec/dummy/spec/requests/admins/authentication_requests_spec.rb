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
        expect(response.headers['Access-Token']).not_to eq('')
        expect(response.headers['Refresh-Token']).not_to eq('')
      end
    end
  end
end
