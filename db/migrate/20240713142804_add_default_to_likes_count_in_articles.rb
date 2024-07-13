class AddDefaultToLikesCountInArticles < ActiveRecord::Migration[7.1]
  def change
    change_column_default :articles, :likes_count, 0
  end
end
