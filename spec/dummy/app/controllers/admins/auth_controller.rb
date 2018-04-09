module Admins
  class AuthController < RabbitApi::AuthenticationController
    before_action :find_resource, only: [:create]

    def create
      if resource.authenticate(params[:password])
        create_token_and_set_header
        render_success(data: resource)
      else
        render_error(401, message: 'Invalid admin credentials')
      end
    end

    def destroy
      super
    end
  end

  private

  def find_resource
    self.resource = Admin.find_by(email: params[:email])
    render_error(401, message: 'Invalid admin credentials') unless resource
  end
end
