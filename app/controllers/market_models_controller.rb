class MarketModelsController < ResourceController
  respond_to :html
  respond_to :js, only: :update

  before_filter :fetch_market_model
  after_filter :clear_jobs, only: %i(update replace)

  # PATCH /testing_grounds/:id/market_models/:id
  def update
    @market_model.update_attributes(market_model_params)
  end

  # POST /testing_grounds/:id/:market_models/:id/replace
  def replace
    other_id = params.require(:replacement_id)
    source_model = MarketModelTemplate.find(other_id)

    @market_model.update_attributes(source_model.attributes_for_market_model)
    redirect_to edit_testing_ground_url(@market_model.testing_ground)
  end

  private

  def clear_jobs
    if @market_model.testing_ground.business_case
      @market_model.testing_ground.business_case.clear_job!
    end
  end

  def market_model_params
    params.require(:market_model).permit(:interactions)
  end

  def fetch_market_model
    @market_model = MarketModel.find(params[:id])
    authorize @market_model
  end
end
