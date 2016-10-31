class MarketModelsController < ResourceController
  respond_to :html
  respond_to :js, only: :update

  before_filter :fetch_market_model

  # PATCH /testing_grounds/:id/market_models/:id
  def update
    @market_model.update_attributes(market_model_params)

    if @market_model.testing_ground.business_case
      @market_model.testing_ground.business_case.clear_job!
    end
  end

  private

  def market_model_params
    params.require(:market_model).permit(:interactions)
  end

  def fetch_market_model
    @market_model = MarketModel.find(params[:id])
    authorize @market_model
  end
end
