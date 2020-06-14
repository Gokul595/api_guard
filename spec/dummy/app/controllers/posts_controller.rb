# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :authenticate_and_set_user_or_admin

  def index
    if @current_user && @current_user.posts
      posts = current_user.posts
    elsif @current_admin
      posts = Post.all
    end

    render json: posts.as_json
  end
end
