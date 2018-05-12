require 'dummy/spec/rails_helper'

describe 'Registration - Admin', type: :request do
  before(:each) do
    RabbitApi.generate_refresh_token = false
  end

  after(:each) do
    RabbitApi.generate_refresh_token = true
  end

  describe 'POST #create' do
    context 'with invalid params' do
      it 'should raise exception - missing param' do
        expect {
          post "/admins/sign_up"
        }.to raise_error ActionController::ParameterMissing
      end

      it 'should return 422 - email blank' do
        post "/admins/sign_up", params: { admin: attributes_for(:admin).except(:email) }

        expect(response).to have_http_status(422)
        expect(response_errors).to include("Email can't be blank")
      end
    end

    context 'with valid params' do
      it 'should create a new admin' do
        expect do
          post "/admins/sign_up", params: { admin: attributes_for(:admin) }
        end.to change(Admin, :count).by(1)

        expect(response).to have_http_status(200)
        expect(response_data['id']).to eq(Admin.last.id)
      end
    end
  end
end
