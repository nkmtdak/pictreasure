class PhotosController < ApplicationController
  protect_from_forgery with: :null_session, only: [:similarity_check, :create]
  before_action :set_challenge

  def similarity_check
    photo = @challenge.photos.new(image: params[:photo][:image])
    process_photo(photo, save: false)
  end

  def create
    @photo = @challenge.photos.build(photo_params)
    @photo.user = current_user
  
    if @photo.save
      render json: { 
        success: true, 
        photo: {
          id: @photo.id,
          image_url: url_for(@photo.image),
          similarity: @photo.similarity
        }
      }, status: :created
    else
      render json: { success: false, errors: @photo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_challenge
    @challenge = Challenge.find(params[:challenge_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'チャレンジが見つかりません' }, status: :not_found
  end

  def photo_params
    params.require(:photo).permit(:image)
  end

  def process_photo(photo, save:)
    Rails.logger.info "Processing photo for challenge: #{@challenge.id}, Save: #{save}"

    if save && !photo.save
      error_message = photo.errors.full_messages.join(', ')
      Rails.logger.error "Failed to save photo: #{error_message}"
      render json: { success: false, error: error_message }, status: :unprocessable_entity
      return
    end

    similarity = photo.calculate_similarity
    photo.update(similarity:) if save
    cleared = similarity >= 0.7

    image_url = if photo.image.attached?
                  url_for(photo.image)
                else
                  '/images/default-photo.jpg' # デフォルト画像のパスを指定
                end

    Rails.logger.info "Photo processed successfully. Similarity: #{similarity}, Cleared: #{cleared}"

    render json: {
      success: true,
      similarity:,
      cleared:,
      photo: {
        id: photo.id,
        image_url: image_url,
        similarity:
      }
    }
  rescue StandardError => e
    Rails.logger.error "Error processing photo: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { success: false, error: '写真の処理中にエラーが発生しました' }, status: :unprocessable_entity
  end
end