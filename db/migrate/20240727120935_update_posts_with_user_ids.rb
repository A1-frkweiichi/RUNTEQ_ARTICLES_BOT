class UpdatePostsWithUserIds < ActiveRecord::Migration[7.1]
  def up
    Post.find_each do |post|
      user_id = post.article.user_id
      post.update_column(:user_id, user_id)
    end
  end

  def down
    Post.update_all(user_id: nil)
  end
end
