class PhotosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_challenge

  def new
    @photo = @challenge.photos.new
  end

  def create
    @challenge = Challenge.find(params[:challenge_id])
    @photo = @challenge.photos.build(photo_params)
    @photo.user = current_user
  
    if @photo.save
      similarity = calculate_similarity(@challenge, @photo)
      @photo.update(similarity: similarity)
      cleared = similarity >= 0.7 # 70%以上で成功とする
  
      render json: {
        success: true,
        similarity: similarity,
        cleared: cleared,
        photo: {
          title: @photo.title,
          image_url: url_for(@photo.image),
          similarity: similarity
        }
      }
    else
      render json: { success: false, error: @photo.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  rescue => e
    render json: { success: false, error: e.message }, status: :internal_server_error
  end

  def similarity_check
    photo = @challenge.photos.new(image: params[:image])
    similarity = calculate_similarity(@challenge, photo)
    cleared = similarity >= 0.7 # 70%以上で成功とする

    render json: {
      similarity: similarity,
      cleared: cleared
    }
  end

  private

  def calculate_similarity(challenge, photo)
    require 'phashion'

    begin
      # チャレンジの画像のパスを取得
      challenge_image_path = ActiveStorage::Blob.service.path_for(challenge.image.key)

      # アップロードされた写真のパスを取得
      if photo.is_a?(ActionDispatch::Http::UploadedFile) || photo.is_a?(Tempfile)
        photo_path = photo.path
      else
        photo_path = ActiveStorage::Blob.service.path_for(photo.image.key)
      end

      # Phashionオブジェクトを作成
      challenge_phash = Phashion::Image.new(challenge_image_path)
      photo_phash = Phashion::Image.new(photo_path)

      # ハミング距離を計算（0は完全一致、1は最大の違い）
      hamming_distance = challenge_phash.distance_from(photo_phash)

      # ハミング距離を0-1の類似度に変換（1が完全一致、0が最大の違い）
      similarity = 1 - (hamming_distance / 64.0)

      # 類似度を返す
      similarity
    rescue => e
      Rails.logger.error "Error calculating similarity: #{e.message}"
      # エラーが発生した場合は0（最低の類似度）を返す
      0
    end
  end

  def set_challenge
    @challenge = Challenge.find(params[:challenge_id])
  end

  def photo_params
    params.require(:photo).permit(:title, :image)
  end

end