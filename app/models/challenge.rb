class Challenge < ApplicationRecord
  belongs_to :user
  has_many :photos
  has_one_attached :thumbnail
  has_one_attached :image

  validates :title, presence: true
  validates :description, presence: true
  validates :image, presence: true

  validate :acceptable_image

  scope :cleared, -> { where(cleared: true) }
  scope :not_cleared, -> { where(cleared: false) }

  def calculate_image_hash
    # 既存のコード
  end

  def cleared?
    Rails.cache.fetch("challenge_#{id}_cleared", expires_in: 1.hour) do
      photos.exists?(similarity: 0.7..Float::INFINITY)
    end
  end

  def update_clear_status
    new_cleared_status = photos.exists?(similarity: 0.7..Float::INFINITY)
    update(cleared: new_cleared_status)
    Rails.cache.delete("challenge_#{id}_cleared")
  end

  def highest_similarity
    Rails.cache.fetch("challenge_#{id}_highest_similarity", expires_in: 1.hour) do
      photos.maximum(:similarity) || 0
    end
  end

  def recalculate_highest_similarity
    new_highest_similarity = photos.maximum(:similarity) || 0
    update(highest_similarity: new_highest_similarity)
    Rails.cache.delete("challenge_#{id}_highest_similarity")
  end

  private

  def acceptable_image
    return unless image.attached?

    errors.add(:image, 'must be less than 5MB') unless image.blob.byte_size <= 5.megabytes

    acceptable_types = ['image/png', 'image/jpg', 'image/jpeg']
    return if acceptable_types.include?(image.content_type)

    errors.add(:image, 'must be a PNG, JPG, or JPEG')
  end
end
