class Photo < ApplicationRecord
  belongs_to :user
  belongs_to :challenge
  has_one_attached :image

  validates :image, presence: true

  after_create_commit :enqueue_similarity_calculation

  SIMILARITY_THRESHOLD = 0.9 # 類似度の閾値を設定

  def calculate_similarity
    challenge_image = MiniMagick::Image.read(challenge.image.download)
    uploaded_image = MiniMagick::Image.read(image.download)

    challenge_phash = Phashion::Image.new(challenge_image.path)
    uploaded_phash = Phashion::Image.new(uploaded_image.path)

    distance = challenge_phash.distance_from(uploaded_phash)
    max_distance = 64.0 # 最大ハミング距離
    1 - (distance / max_distance)
  rescue StandardError => e
    Rails.logger.error "Error calculating similarity: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    nil
  end

  def similar_to_challenge?
    similarity >= SIMILARITY_THRESHOLD
  end

  def phash_fingerprint(attachment)
    return nil unless attachment.attached?

    attachment.open do |file|
      Phashion::Image.new(file.path).fingerprint
    end
  rescue StandardError => e
    Rails.logger.error "Error calculating pHash fingerprint: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    nil
  end

  private

  def enqueue_similarity_calculation
    SetSimilarityJob.perform_later(id)
  end
end
