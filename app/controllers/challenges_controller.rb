class ChallengesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_challenge, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user, only: [:edit, :update, :destroy]

  def index
    @challenges = Challenge.includes(:photos, :user, image_attachment: :blob).all
  end

  def show
    @photos = @challenge.photos
    @latest_similarity = @photos.order(created_at: :desc).first&.similarity if @photos.present?
  end

  def new
    @challenge = Challenge.new
  end

  def create
    @challenge = current_user.challenges.build(challenge_params)
    if @challenge.save
      redirect_to @challenge, notice: 'チャレンジが正常に作成されました。'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @challenge.update(challenge_params)
      redirect_to @challenge, notice: 'チャレンジが正常に更新されました。'
    else
      render :edit
    end
  end

  def destroy
    @challenge.destroy
    redirect_to challenges_path, notice: 'チャレンジが正常に削除されました。'
  end

  def start
    @challenge = YAML.load_file(Rails.root.join('config', 'challenges.yml'))['challenges'].sample
  end

  private

  def challenge_params
    params.require(:challenge).permit(:title, :description, :image, :thumbnail, :theme_image)
  end

  def set_challenge
    @challenge = Challenge.includes(:photos, :user, image_attachment: :blob).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to challenges_path, alert: 'Challenge not found.'
  end
  
  def authorize_user
    unless current_user && (current_user.admin? || @challenge.user == current_user)
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to challenges_path
    end
  end

  def calculate_similarity(challenge, photo)
    challenge_hash = challenge.calculate_image_hash
    photo_hash = photo.calculate_image_hash
    hamming_distance = (challenge_hash ^ photo_hash).to_s(2).count("1")
    1 - (hamming_distance.to_f / 64)
  end
end