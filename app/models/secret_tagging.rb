class SecretTagging < ActiveRecord::Base
  validates :tag_id, presence: true
  belongs_to :secret
  belongs_to :tag
end
