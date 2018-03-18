require 'dummy/spec/rails_helper'

describe 'Registration - User', type: :request do
  describe 'POST #create' do
    it_behaves_like 'sign_up requests', 'user'
  end
end
