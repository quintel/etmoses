class LoadProfileComponentController < ApplicationController
  skip_before_filter :authenticate_user!

  respond_to :json, only: :show

  def show
    profile_component = LoadProfileComponent.find(params[:id]).as_json

    respond_with(profile_component.update("values" =>
      TestingGround::TreeSampler.downsample(profile_component.fetch("values"), :low)
    ))
  end
end
