class Photo < ApplicationRecord
  belongs_to :user
  belongs_to :challenge
  has_one_attached :image

  validates :image, presence: true

  after_create_commit :enqueue_similarity_calculation

  SIMILARITY_THRESHOLD = 0.9 # 類似度の閾値を設定

  def calculate_similarity
    Rails.logger.debug "Starting similarity calculation for Photo ID: #{id}"
    return 0 unless image.attached? && challenge.image.attached?

    begin
      photo_hash = phash_fingerprint(image)
      challenge_hash = phash_fingerprint(challenge.image)

      Rails.logger.debug "Photo hash: #{photo_hash}"
      Rails.logger.debug "Challenge hash: #{challenge_hash}"

      return 0 if photo_hash.nil? || challenge_hash.nil?

      distance = Phashion.hamming_distance(photo_hash, challenge_hash)
      Rails.logger.debug "Hamming distance: #{distance}"
      similarity = 1 - (distance / 64.0)  # pHashは64ビットのハッシュを使用
      rounded_similarity = similarity.round(4)
      Rails.logger.debug "Calculated similarity: #{rounded_similarity}"
      rounded_similarity
    rescue => e
      Rails.logger.error "Error in calculate_similarity: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      0
    end
  end

  def similar_to_challenge?
    similarity >= SIMILARITY_THRESHOLD
  end

  def phash_fingerprint(attachment)
    return nil unless attachment.attached?

    begin
      attachment.open do |file|
        Phashion::Image.new(file.path).fingerprint
      end
    rescue => e
      Rails.logger.error "Error calculating pHash fingerprint: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      nil
    end
  end

  private

  def enqueue_similarity_calculation
    SetSimilarityJob.perform_later(id)
  end
end