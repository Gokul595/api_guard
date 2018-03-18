require 'dummy/spec/rails_helper'

describe 'Registration - Admin', type: :request do
  describe 'POST #create' do
    it_behaves_like 'sign_up requests', 'admin'
  end
end
