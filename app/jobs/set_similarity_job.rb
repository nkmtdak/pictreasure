class SetSimilarityJob < ApplicationJob
  queue_as :default

  def perform(photo_id)
    photo = Photo.find(photo_id)
    similarity = photo.calculate_similarity
    if similarity
      photo.update(similarity:)
    else
      Rails.logger.error "Failed to calculate similarity for Photo ID: #{photo_id}"
    end
  rescue StandardError => e
    Rails.logger.error "Error in SetSimilarityJob: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end
