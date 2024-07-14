class AddIsActiveToArticles < ActiveRecord::Migration[7.1]
  def change
    add_column :articles, :is_active, :boolean, default: true, null: false
  end
end
