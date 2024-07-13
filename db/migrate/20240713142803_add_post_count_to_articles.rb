class AddPostCountToArticles < ActiveRecord::Migration[7.1]
  def change
    add_column :articles, :post_count, :integer, default: 0, null: false
  end
end
