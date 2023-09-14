# frozen_string_literal: true

require 'dummy/spec/rails_helper'

describe 'Admins::Posts with custom token payload', type: :request do
  before :each, create_post: true do
    user = create(:user)
    @post = create(:post, user_id: user.id)
  end

  describe 'GET #index' do
    context 'with invalid params' do
      it 'should return 401 - missing access token' do
        patch '/admins/posts/1'

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Access token is missing in the request')
      end

      it 'should return 401 - invalid access token' do
        patch '/admins/posts/1', headers: { 'Authorization': 'Bearer invalid_token' }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Invalid access token')
      end

      it 'should return 401 - expired access token' do
        admin = create(:admin)
        expired_access_token = jwt_and_refresh_token(admin, 'admin', true)[0]

        patch '/admins/posts/1', headers: { 'Authorization': "Bearer #{expired_access_token}" }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Access token expired')
      end

      it 'should return 401 - revoked access token' do
        admin = create(:admin)
        access_token = jwt_and_refresh_token(admin, 'admin')[0]

        admin.revoked_tokens.create(token: access_token, expire_at: Time.now.utc)

        patch '/admins/posts/1', headers: { 'Authorization': "Bearer #{access_token}" }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Invalid access token')
      end

      it 'should return 401 - old access token' do
        admin = create(:admin)
        access_token = jwt_and_refresh_token(admin, 'admin')[0]

        admin.update(token_issued_at: Time.now.utc + 1.second)

        patch '/admins/posts/1', headers: { 'Authorization': "Bearer #{access_token}" }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Invalid access token')
      end

      it 'should return 401 when an admin try to edit post without edit_all_posts rights', create_post: true do
        admin = create(:admin)

        access_token = jwt_and_refresh_token(admin, 'admin')[0]

        patch "/admins/posts/#{@post.id}",
              params: { post: { content: 'Edited.' } },
              headers: { 'Authorization': "Bearer #{access_token}" }

        expect(response).to have_http_status(401)
        expect(@post.reload.content).not_to eq('Edited.')
      end
    end

    context 'with valid params' do
      it 'should allow editing post when the admin has edit_all_posts rights', create_post: true do
        admin = create(:admin, edit_all_posts: true)

        access_token = jwt_and_refresh_token(admin, 'admin')[0]

        patch "/admins/posts/#{@post.id}",
              params: { post: { content: 'Edited.' } },
              headers: { 'Authorization': "Bearer #{access_token}" }

        expect(response).to have_http_status(200)
        expect(parsed_response['content']).to eq('Edited.')
      end

      it 'should allow editing post when token has force_allow_editing_post value in the payload', create_post: true do
        admin = create(:admin)

        def admin.jwt_token_payload
          { force_allow_editing_post: true }
        end

        access_token = jwt_and_refresh_token(admin, 'admin')[0]

        patch "/admins/posts/#{@post.id}",
              params: { post: { content: 'Edited.' } },
              headers: { 'Authorization': "Bearer #{access_token}" }

        expect(response).to have_http_status(200)
        expect(parsed_response['content']).to eq('Edited.')
      end
    end
  end
end
