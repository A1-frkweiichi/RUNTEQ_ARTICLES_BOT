class CreateArticles < ActiveRecord::Migration[7.1]
  def change
    create_table :articles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :source_platform, null: false
      t.string :external_id, null: false
      t.string :title, null: false
      t.string :article_url, null: false
      t.datetime :published_at, null: false
      t.integer :likes_count, null: false

      t.timestamps
    end

    add_index :articles, :external_id, unique: true
  end
end
