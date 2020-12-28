# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :authenticate_and_set_user_or_admin

  def index
    posts = current_user.posts if @current_user
    posts = Post.all if @current_admin
    render json: posts.as_json
  end
end
