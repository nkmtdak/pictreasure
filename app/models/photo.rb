class Photo < ApplicationRecord
  belongs_to :user
  belongs_to :challenge

  validates :title, presence: true
  has_one_attached :image

  def calculate_image_hash
    image_path = ActiveStorage::Blob.service.path_for(image.key)
    Phashion::Image.new(image_path).fingerprint
  end
end
