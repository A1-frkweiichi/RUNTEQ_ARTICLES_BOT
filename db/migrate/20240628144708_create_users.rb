class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :mattermost_id, null: false
      t.string :qiita_username
      t.string :zenn_username

      t.timestamps
    end

    add_index :users, :mattermost_id, unique: true
    add_index :users, :qiita_username
    add_index :users, :zenn_username
  end
end
