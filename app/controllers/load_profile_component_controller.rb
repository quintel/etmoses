class LoadProfileComponentController < ApplicationController
  skip_before_filter :authenticate_user!

  respond_to :json, only: :show

  def show
    respond_with(LoadProfileComponent.find(params[:id]))
  end
end
