class PhotosController < ApplicationController
  before_action :authenticate_user!

  def new
    @challenge = Challenge.find(params[:challenge_id])
    @photo = @challenge.photos.new
  end

  def create
    @challenge = Challenge.find(params[:challenge_id])
    @photo = @challenge.photos.build(photo_params)
    @photo.user = current_user

    if @photo.save
      redirect_to @challenge, notice: 'Photo was successfully uploaded.'
    else
      render :new
    end
  end

  private

  def check_similarity
    challenge_hash = @challenge.calculate_image_hash
    photo_hash = @photo.calculate_image_hash
    hamming_distance = (challenge_hash ^ photo_hash).to_s(2).count("1")
    similarity = 1 - (hamming_distance.to_f / 64)
    
    if similarity >= 0.9 # 90%以上の類似度でクリアとする
      # チャレンジクリアの処理
      @challenge.update(cleared: true)
      flash[:success] = "Challenge cleared! Similarity: #{(similarity * 100).round(2)}%"
    else
      flash[:notice] = "Not quite there. Similarity: #{(similarity * 100).round(2)}%"
    end
  end

  def photo_params
    params.require(:photo).permit(:title, :image)
  end
end
