class AddPasswordAndDeletedAtToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :password_digest, :string
    add_column :users, :deleted_at, :datetime
    add_index :users, :deleted_at
  end
end
