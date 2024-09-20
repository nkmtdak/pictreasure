class PhotosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_challenge, only: [:create]
  before_action :set_photo, only: [:check_similarity]

  def create
    @photo = @challenge.photos.build(photo_params)
    @photo.user = current_user

    if @photo.save
      SetSimilarityJob.perform_later(@photo.id)
      render json: {
        success: true,
        photo: {
          id: @photo.id,
          image_url: url_for(@photo.image)
        },
        message: '写真がアップロードされました。類似度を計算中です。'
      }, status: :created
    else
      render json: { success: false, errors: @photo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def check_similarity
    render json: {
      similarity: @photo.similarity,
      cleared: @photo.similarity && @photo.similarity >= 0.7,
      image_url: url_for(@photo.image)
    }
  end

  private

  def set_challenge
    @challenge = Challenge.find(params[:challenge_id])
  end

  def set_photo
    @photo = Photo.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: '写真が見つかりません' }, status: :not_found
  end

  def photo_params
    params.require(:photo).permit(:image)
  end
end
