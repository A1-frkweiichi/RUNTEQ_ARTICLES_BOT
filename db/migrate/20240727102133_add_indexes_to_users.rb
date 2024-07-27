class AddIndexesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_index :users, [:qiita_username, :zenn_username], name: 'index_users_on_qiita_and_zenn_usernames'
  end
end
