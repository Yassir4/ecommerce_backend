class CurrentUserController < ApplicationController
  before_action :authenticate_user!
  def index
    render json: current_user
  end

end
