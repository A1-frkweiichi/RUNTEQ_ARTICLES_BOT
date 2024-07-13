class Post < ApplicationRecord
  belongs_to :article
  enum status: { pending: 'pending', success: 'success', failed: 'failed' }
end
