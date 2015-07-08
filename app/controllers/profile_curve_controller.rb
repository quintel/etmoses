class ProfileCurveController < ApplicationController
  respond_to :json, only: :show

  def show
    respond_with(@profile_curve = ProfileCurve.find(params[:id]))
  end
end
