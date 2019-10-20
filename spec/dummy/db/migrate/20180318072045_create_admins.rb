# frozen_string_literal: true

class CreateAdmins < ActiveRecord::Migration[5.1]
  def change
    create_table :admins do |t|
      t.string :email
      t.string :password_digest

      t.timestamps
    end
  end
end
