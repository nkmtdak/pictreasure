class Photo < ApplicationRecord
  belongs_to :user
  belongs_to :challenge

  validates :title, presence: true
  has_one_attached :image
end
