require 'dummy/spec/rails_helper'

describe 'Registration - Customer(User)', type: :request do
  describe 'POST #create' do
    context 'with valid params' do
      it 'should create a new customer (i.e.) User' do
        expect do
          post "/customers/sign_up", params: { customer: attributes_for(:user) }
        end.to change(User, :count).by(1)

        expect(response).to have_http_status(200)
        expect(response_data['id']).to eq(User.last.id)
      end
    end
  end
end
