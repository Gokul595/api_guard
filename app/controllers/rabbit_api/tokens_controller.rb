module Api
  module V1
    class TokensController < Api::V1::ApiController
      before_action :find_refresh_token, only: [:create]

      def create
        create_token_and_set_header # Create JWT token and refresh token
        render_success(data: @user)
      end

      private

      def find_refresh_token
        refresh_token = request.headers['Refresh-Token']

        if refresh_token
          @refresh_token = @user.refresh_token

          render_controller_error(401, 'Invalid refresh token', :refresh_token_invalid) unless @refresh_token.token == refresh_token
        else
          render_controller_error(401, 'Refresh token is missing in the request', :refresh_token_missing)
        end
      end
    end
  end
end
