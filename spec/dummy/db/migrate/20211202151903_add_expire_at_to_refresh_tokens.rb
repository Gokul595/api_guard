class AddExpireAtToRefreshTokens < ActiveRecord::Migration[6.0]
  def change
    add_column :refresh_tokens, :expire_at, :datetime
  end
end
