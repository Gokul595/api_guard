# frozen_string_literal: true

class CreateRevokedTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :revoked_tokens do |t|
      t.string :token
      t.datetime :expire_at
      t.references :user, foreign_key: true
      t.references :admin, foreign_key: true

      t.timestamps
    end
  end
end
