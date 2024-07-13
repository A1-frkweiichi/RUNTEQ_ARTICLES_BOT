class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_enum :post_status, %w[pending success failed]

    create_table :posts do |t|
      t.references :article, null: false, foreign_key: true
      t.column :status, :post_status, null: false, default: 'pending'

      t.timestamps
    end
  end
end
