class PriceCurvesController < ProfilesController
  def profile_params
    params.require(:price_curve).permit(:key, :type, :name, :curve, :public)
  end
end
