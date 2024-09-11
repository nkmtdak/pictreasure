class Photo < ApplicationRecord
  belongs_to :user
  belongs_to :challenge
  has_one_attached :image

  after_save :log_save
  after_create :log_create

  def calculate_image_hash
    return nil unless image.attached?

    image_path = ActiveStorage::Blob.service.path_for(image.key)
    Phashion::Image.new(image_path).fingerprint
  rescue => e
    Rails.logger.error "Error calculating image hash: #{e.message}"
    nil
  end

  private

  def log_save
    Rails.logger.debug "Photo saved: #{self.inspect}"
  end

  def log_create
    Rails.logger.debug "Photo created: #{self.inspect}"
  end
end