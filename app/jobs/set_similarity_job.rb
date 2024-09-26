class SetSimilarityJob < ApplicationJob
  queue_as :default

  def perform(photo_id)
    Rails.logger.info "Starting SetSimilarityJob for Photo ID: #{photo_id}"

    photo = Photo.find(photo_id)
    Rails.logger.info "Found photo with ID: #{photo_id}"

    similarity = photo.calculate_similarity
    Rails.logger.info "Calculated similarity for Photo ID: #{photo_id}, Similarity: #{similarity}"

    if similarity
      result = photo.update(similarity:)
      if result
        Rails.logger.info "Successfully updated similarity for Photo ID: #{photo_id}"
      else
        Rails.logger.error "Failed to update similarity for Photo ID: #{photo_id}. Errors: #{photo.errors.full_messages}"
      end
    else
      Rails.logger.error "Failed to calculate similarity for Photo ID: #{photo_id}"
    end
  rescue StandardError => e
    Rails.logger.error "Error in SetSimilarityJob for Photo ID: #{photo_id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  ensure
    Rails.logger.info "Finished SetSimilarityJob for Photo ID: #{photo_id}"
  end
end
