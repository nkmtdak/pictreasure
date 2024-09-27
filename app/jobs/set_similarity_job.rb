class SetSimilarityJob < ApplicationJob
  queue_as :default

  def perform(photo_id)
    Rails.logger.info "Starting SetSimilarityJob for Photo ID: #{photo_id}"

    photo = Photo.find(photo_id)
    similarity = photo.calculate_similarity

    if similarity
      if photo.update(similarity: similarity)
        Rails.logger.info "Updated similarity for Photo ID: #{photo_id}, Similarity: #{similarity}"
        
        # チャレンジのクリア状態を更新
        if similarity >= 0.7 && !photo.challenge.cleared?
          photo.challenge.update(cleared_at: Time.current)
          Rails.logger.info "Challenge cleared for Photo ID: #{photo_id}"
        end
      else
        Rails.logger.error "Failed to update similarity for Photo ID: #{photo_id}"
      end
    else
      Rails.logger.error "Failed to calculate similarity for Photo ID: #{photo_id}"
    end
  rescue StandardError => e
    Rails.logger.error "Error in SetSimilarityJob for Photo ID: #{photo_id}: #{e.message}"
  ensure
    Rails.logger.info "Finished SetSimilarityJob for Photo ID: #{photo_id}"
  end
end