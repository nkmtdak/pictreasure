class PhotosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_challenge, only: [:create]
  before_action :set_photo, only: [:check_similarity]

  def create
    @photo = @challenge.photos.build(photo_params)
    @photo.user = current_user
  
    if @photo.save
      Rails.logger.info "Photo saved successfully. ID: #{@photo.id}"
      SetSimilarityJob.perform_later(@photo.id)
      Rails.logger.info "SetSimilarityJob enqueued for Photo ID: #{@photo.id}"
      
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.prepend('messages', partial: 'shared/flash_message', locals: { message: "写真がアップロードされました。類似度を計算中です。", type: 'success' })
        }
        format.json {
          render json: {
            success: true,
            photo: {
              id: @photo.id,
              image_url: url_for(@photo.image)
            },
            message: '写真がアップロードされました。類似度を計算中です。'
          }, status: :created
        }
      end
    else
      Rails.logger.error "Failed to save photo: #{@photo.errors.full_messages.join(', ')}"
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.prepend('messages', partial: 'shared/flash_message', locals: { message: @photo.errors.full_messages.join(", "), type: 'danger' })
        }
        format.json { render json: { success: false, errors: @photo.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def check_similarity
    Rails.logger.info "Checking similarity for Photo ID: #{@photo.id}"
    Rails.logger.info "Current similarity: #{@photo.similarity}, Status: #{@photo.similarity.nil? ? 'processing' : 'completed'}"
    
    render json: {
      similarity: @photo.similarity,
      cleared: @photo.similarity && @photo.similarity >= 0.7,
      image_url: url_for(@photo.image),
      status: @photo.similarity.nil? ? 'processing' : 'completed'
    }
  end

  private

  def set_challenge
    @challenge = Challenge.find(params[:challenge_id])
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "Challenge not found with ID: #{params[:challenge_id]}"
    render json: { error: 'チャレンジが見つかりません' }, status: :not_found
  end

  def set_photo
    @photo = Photo.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "Photo not found with ID: #{params[:id]}"
    render json: { error: '写真が見つかりません' }, status: :not_found
  end

  def photo_params
    params.require(:photo).permit(:image)
  end
end