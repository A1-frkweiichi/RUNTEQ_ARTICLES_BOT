class AddIsPostableToArticles < ActiveRecord::Migration[7.1]
  def change
    add_column :articles, :is_postable, :boolean, default: false
  end
end
