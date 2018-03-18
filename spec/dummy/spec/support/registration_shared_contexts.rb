shared_context 'sign_up requests' do |resource|
  context 'with valid params' do
    it 'should raise exception - missing param' do
      expect {
        post "/#{resource}s/sign_up"
      }.to raise_error ActionController::ParameterMissing
    end

    it 'should return 422 - email blank' do
      post "/#{resource}s/sign_up", params: { "#{resource}": attributes_for(:"#{resource}").except(:email) }

      expect(response).to have_http_status(422)
      expect(response_errors).to include("Email can't be blank")
    end
  end

  context 'with valid params' do
    it 'should create a new user' do
      expect do
        post "/#{resource}s/sign_up", params: { "#{resource}": attributes_for(:"#{resource}") }
      end.to change(resource.capitalize.constantize, :count).by(1)

      expect(response).to have_http_status(200)
      expect(response_data['id']).to eq(resource.capitalize.constantize.last.id)
    end
  end
end
