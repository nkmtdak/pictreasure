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

  def photo_params
    params.require(:photo).permit(:title, :image)
  end
end
