class AddCompositeIndexesToArticles < ActiveRecord::Migration[7.1]
  def change
    remove_index :articles, name: "index_articles_on_external_id"

    add_index :articles, [:external_id, :source_platform], unique: true, name: 'index_articles_on_external_id_and_source_platform'

    add_index :articles, [:user_id, :is_postable, :is_active, :published_at, :likes_count], name: 'index_articles_on_user_postable_active_published_likes'
  end
end
