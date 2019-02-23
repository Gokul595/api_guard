class AddTokenIssuedAt < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :token_issued_at, :datetime
    add_column :admins, :token_issued_at, :datetime
  end
end
