# frozen_string_literal: true

module Admins
  class PostsController < ApplicationController
    before_action :authenticate_and_set_admin

    def update
      post = Post.find(params[:id])
      post.update(content: params[:post][:content])

      render json: post.as_json
    end

    private

    def find_resource_from_token(resource_class)
      admin = super
      admin if admin.edit_all_posts? || @decoded_token[:force_allow_editing_post]
    end
  end
end
