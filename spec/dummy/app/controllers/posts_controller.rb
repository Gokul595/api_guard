# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :authenticate_and_set_user

  def index
    posts = current_user.posts
    render json: posts.as_json
  end
end
