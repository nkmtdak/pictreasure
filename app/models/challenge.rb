class Challenge < ApplicationRecord
  belongs_to :user
  has_many :photos
  has_one_attached :thumbnail
  has_one_attached :image

  def calculate_image_hash
    image_path = ActiveStorage::Blob.service.path_for(image.key)
    Phashion::Image.new(image_path).fingerprint
  end

  validates :title, presence: true
  validates :description, presence: true

end
