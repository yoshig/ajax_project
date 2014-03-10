class Tag < ActiveRecord::Base
  validates :name, presence: true

  has_many :secret_taggings
  has_many :users, through: :secret_taggings
end
