class Secret < ActiveRecord::Base
  belongs_to :author, :class_name => "User"
  belongs_to :recipient, :class_name => "User"

  validates :author_id, :recipient_id, :title, :presence => true
end
