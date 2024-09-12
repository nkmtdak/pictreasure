class PhotosController < ApplicationController
  protect_from_forgery with: :null_session, only: [:similarity_check, :create]
  before_action :set_challenge

  def similarity_check
    photo = @challenge.photos.new(image: params[:photo][:image])
    process_photo(photo, save: false)
  end

  def create
    photo = @challenge.photos.build(photo_params)
    photo.user = current_user
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
    if save && !photo.save
      render json: { success: false, error: photo.errors.full_messages.join(", ") }, status: :unprocessable_entity
      return
    end

    similarity = photo.calculate_similarity
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
    render json: { success: false, error: "写真の処理中にエラーが発生しました" }, status: :unprocessable_entity
  end
end