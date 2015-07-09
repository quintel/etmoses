class LoadProfileComponentController < ApplicationController
  respond_to :json, only: :show

  def show
    respond_with(LoadProfileComponent.find(params[:id]))
  end
end
