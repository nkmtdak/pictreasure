class Challenge < ApplicationRecord
  belongs_to :user
  has_many :photos

  validates :title, presence: true
  validates :description, presence: true

end
