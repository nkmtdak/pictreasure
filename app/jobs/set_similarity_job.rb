class SetSimilarityJob < ApplicationJob
  queue_as :default

  def perform(photo_id)
    photo = Photo.find(photo_id)
    Rails.logger.debug "Setting similarity for Photo ID: #{photo.id}"

    calculated_similarity = photo.calculate_similarity
    Rails.logger.debug "Calculated similarity: #{calculated_similarity}"

    photo.update(similarity: calculated_similarity)
    Rails.logger.debug "Updated similarity: #{photo.similarity}"
  rescue StandardError => e
    Rails.logger.error "Error in SetSimilarityJob: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end
