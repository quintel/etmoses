class LoadCurveController < ApplicationController
  respond_to :json, only: :show

  def show
    @load_curve = LoadCurve.find(params[:id])

    respond_with(@load_curve)
  end
end
