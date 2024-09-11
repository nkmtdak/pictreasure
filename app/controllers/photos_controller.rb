require 'phashion'

class PhotosController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :set_challenge

  def similarity_check
    photo = @challenge.photos.new(image: params[:photo][:image])
    process_photo(photo, save: false)
  end

  def create
    Rails.logger.debug "Starting create action"
    Rails.logger.debug "Params: #{params.inspect}"
    
    photo = @challenge.photos.build(photo_params)
    photo.user = current_user

    Rails.logger.debug "Photo built: #{photo.inspect}"
    Rails.logger.debug "Image attached before process: #{photo.image.attached?}"

    process_photo(photo, save: true)
  end

  private
  
  def set_challenge
    @challenge = Challenge.find(params[:challenge_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "チャレンジが見つかりません" }, status: :not_found
  end

  def photo_params
    params.require(:photo).permit(:image)
  end

  def process_photo(photo, save:)
    Rails.logger.debug "Processing photo: #{photo.inspect}, save: #{save}"
    Rails.logger.debug "Image attached before save: #{photo.image.attached?}"

    if save
      if photo.save
        Rails.logger.debug "Photo saved successfully"
        Rails.logger.debug "Image attached after save: #{photo.image.attached?}"
      else
        Rails.logger.error "Photo save failed: #{photo.errors.full_messages}"
        render json: { success: false, error: photo.errors.full_messages.join(", ") }, status: :unprocessable_entity
        return
      end
    end

    begin
      similarity = calculate_similarity(@challenge, photo)
      Rails.logger.debug "Similarity calculated: #{similarity}"

      photo.update(similarity: similarity) if save
      cleared = similarity >= 0.7

      render json: {
        success: true,
        similarity: similarity,
        cleared: cleared,
        photo: {
          id: photo.id,
          image_url: photo.image.attached? ? url_for(photo.image) : nil,
          similarity: similarity
        }
      }
    rescue => e
      Rails.logger.error "Error processing photo: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { success: false, error: "写真の処理中にエラーが発生しました: #{e.message}" }, status: :unprocessable_entity
    end
  end

  def calculate_similarity(challenge, photo)
    Rails.logger.debug "Calculating similarity for challenge: #{challenge.id}, photo: #{photo.id}"
    Rails.logger.debug "Challenge image attached: #{challenge.image.attached?}"
    Rails.logger.debug "Photo image attached: #{photo.image.attached?}"
  
    challenge_image_path = ActiveStorage::Blob.service.path_for(challenge.image.key)
    photo_image_path = ActiveStorage::Blob.service.path_for(photo.image.key)
  
    Rails.logger.debug "Challenge image path: #{challenge_image_path}"
    Rails.logger.debug "Photo image path: #{photo_image_path}"
  
    unless File.exist?(challenge_image_path) && File.exist?(photo_image_path)
      Rails.logger.error "Image file not found"
      return 0
    end
  
    challenge_phash = Phashion::Image.new(challenge_image_path)
    photo_phash = Phashion::Image.new(photo_image_path)
  
    hamming_distance = challenge_phash.distance_from(photo_phash)
    similarity = 1 - (hamming_distance / 64.0)
  
    Rails.logger.debug "Calculated similarity: #{similarity}"
    similarity
  rescue => e
    Rails.logger.error "Similarity calculation error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    0  # エラーの場合は最低の類似度を返す
  end
end