class ChallengesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def index
    @challenges = Challenge.all
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
      render :new
    end
  end

  private

  def challenge_params
    params.require(:challenge).permit(:title, :description)
  end
end
