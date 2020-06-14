# frozen_string_literal: true

require 'dummy/spec/rails_helper'

describe 'Posts', type: :request do
  describe 'GET #index' do
    context 'with invalid params' do
      it 'should return 401 - missing access token' do
        get '/posts'

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Access token is missing in the request')
      end

      it 'should return 401 - invalid access token' do
        get '/posts', headers: { 'Authorization': 'Bearer invalid_token' }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Invalid access token')
      end

      it 'should return 401 - expired access token' do
        user = create(:user)
        expired_access_token = jwt_and_refresh_token(user, 'user', true)[0]

        get '/posts', headers: { 'Authorization': "Bearer #{expired_access_token}" }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Access token expired')
      end

      it 'should return 401 - blacklisted access token' do
        user = create(:user)
        access_token = jwt_and_refresh_token(user, 'user')[0]

        user.blacklisted_tokens.create(token: access_token, expire_at: Time.now.utc)

        get '/posts', headers: { 'Authorization': "Bearer #{access_token}" }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Invalid access token')
      end

      it 'should return 401 - old access token' do
        user = create(:user)
        access_token = jwt_and_refresh_token(user, 'user')[0]

        user.update(token_issued_at: Time.now.utc + 1.second)

        get '/posts', headers: { 'Authorization': "Bearer #{access_token}" }

        expect(response).to have_http_status(401)
        expect(response_errors).to eq('Invalid access token')
      end
    end

    context 'with valid params' do
      context 'as user' do
        let(:user) { create(:user) }
        let(:user1) { create(:user_1) }
        let(:access_token) { jwt_and_refresh_token(user, 'user')[0] }

        it 'should return current user posts' do  
          user_posts = create_list(:post, 2, user_id: user.id)
          create_list(:post, 2, user_id: user1.id)
  
          get '/posts', headers: { 'Authorization': "Bearer #{access_token}" }
  
          expect(response).to have_http_status(200)
          expect(parsed_response.map { |p| p['id'] }).to match_array(user_posts.map(&:id))
        end
      end

      context 'as admin' do
        let(:admin) { create(:admin) }
        let(:user) { create(:user) }
        let(:user1) { create(:user_1) }
        let(:access_token) { jwt_and_refresh_token(admin, 'admin')[0] }

        it 'should return all user posts' do
          user_posts = create_list(:post, 2, user_id: user.id)
          other_user_posts = create_list(:post, 2, user_id: user1.id)
  
          get '/posts', headers: { 'Authorization': "Bearer #{access_token}" }
  
          expect(response).to have_http_status(200)
          expect(parsed_response.map { |p| p['id'] }).to match_array([user_posts.map(&:id), other_user_posts.map(&:id)].flatten)
        end
      end
    end
  end
end
