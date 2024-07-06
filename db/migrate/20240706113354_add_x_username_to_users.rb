class AddXUsernameToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :x_username, :string
    add_index :users, :x_username
  end
end
