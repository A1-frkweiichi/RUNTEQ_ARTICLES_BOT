class Post < ApplicationRecord
  belongs_to :article
  belongs_to :user
  enum status: { pending: 'pending', success: 'success', failed: 'failed' }
end
