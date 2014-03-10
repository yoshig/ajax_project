class Secret < ActiveRecord::Base
  validates :author_id, :recipient_id, :title, :presence => true

  belongs_to :recipient, :class_name => "User"
  belongs_to :author, :class_name => "User"

  has_many :secret_taggings
  has_many :tags, through: :secret_taggings

end
