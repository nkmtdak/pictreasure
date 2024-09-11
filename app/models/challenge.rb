class Challenge < ApplicationRecord
  belongs_to :user
  has_many :photos
  has_one_attached :thumbnail
  has_one_attached :image

  validates :title, presence: true
  validates :description, presence: true
  validates :image, presence: true

  def calculate_image_hash
    return nil unless image.attached?

    begin
      image_path = ActiveStorage::Blob.service.path_for(image.key)
      Phashion::Image.new(image_path).fingerprint
    rescue => e
      Rails.logger.error "Error calculating image hash for Challenge #{id}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      nil
    end
  end

  def cleared?
    photos.exists?(similarity: 0.7..Float::INFINITY)
  end

  def highest_similarity
    photos.maximum(:similarity) || 0
  end
end