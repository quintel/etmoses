class LoadProfileComponentController < ApplicationController
  before_filter :find_load_profile_component

  skip_before_filter :authenticate_user!

  respond_to :json, only: :show

  def show
    @load_profile_component = @load_profile_component.as_json

    respond_with(@load_profile_component.update("values" =>
      TestingGround::TreeSampler.downsample(@load_profile_component.fetch("values"), :low)
    ))
  end

  def download
    send_file @load_profile_component.curve.path,
      filename: @load_profile_component.filename,
      type: 'text/csv'
  end

  private

  def find_load_profile_component
    @load_profile_component = LoadProfileComponent.find(params[:load_profile_component_id] || params[:id])
  end
end
