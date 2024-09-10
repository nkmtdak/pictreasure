class ChallengesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_challenge, only: [:show, :edit, :update, :destroy]
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def index
    @challenges = Challenge.all
    @challenges = Challenge.includes(:photos).all
  end

  def show
    @challenge = Challenge.find(params[:id])
    @photos = @challenge.photos
  end

  def new
    @challenge = Challenge.new
  end

  def create
    @challenge = current_user.challenges.build(challenge_params)
    if @challenge.save
      redirect_to @challenge, notice: 'Challenge was successfully created.'
    else
      flash.now[:alert] = 'There was an error creating the challenge.'
      render :new
    end
  end

  def edit
  end
  
  def update
    if @challenge.update(challenge_params)
      redirect_to @challenge, notice: 'Challenge was successfully updated.'
    else
      flash.now[:alert] = 'There was an error updating the challenge.'
      render :edit
    end
  end
  
  def destroy
    @challenge.destroy
    redirect_to challenges_url, notice: 'Challenge was successfully destroyed.'
  end

  private

  def set_challenge
    @challenge = Challenge.find(params[:id])
  end
  
  def ensure_correct_user
    unless @challenge.user == current_user
      redirect_to challenges_path, alert: 'You are not authorized to perform this action.'
    end
  end

  def challenge_params
    params.require(:challenge).permit(:title, :description)
  end
end
