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
        expect(response_data['id']).to eq(User.last.id)
      end
    end
  end
end
