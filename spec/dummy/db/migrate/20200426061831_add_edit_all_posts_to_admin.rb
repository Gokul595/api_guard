# frozen_string_literal: true

class AddEditAllPostsToAdmin < ActiveRecord::Migration[5.1]
  def change
    add_column :admins, :edit_all_posts, :boolean, default: false
  end
end
