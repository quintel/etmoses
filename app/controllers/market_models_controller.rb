class MarketModelsController < ResourceController
  RESOURCE_ACTIONS = %i(show edit update destroy)

  before_filter :find_market_model, only: RESOURCE_ACTIONS
  before_filter :authorize_generic, except: RESOURCE_ACTIONS

  def index
    @market_models = MarketModel.all
  end

  def new
    @market_model = current_user.market_models.new(interactions: MarketModel::DEFAULT_INTERACTIONS)
  end

  def create
    @market_model = current_user.market_models.new(market_model_params)
    if @market_model.save
      redirect_to market_model_path(@market_model)
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @market_model.update(market_model_params)
      redirect_to market_model_path(@market_model)
    else
      render :edit
    end
  end

  def destroy
    @market_model.destroy
    redirect_to(market_models_path)
  end

  private

  def find_market_model
    @market_model = MarketModel.find(params[:id])
    authorize(@market_model)
  end

  def market_model_params
    mm_params = params.require(:market_model)
      .permit(:name, :public, :interactions)

    if mm_params[:interactions].present?
      mm_params[:interactions] =
        JSON.parse(mm_params[:interactions]).map do |inter|
          if inter['tariff_type'] == 'fixed'
            inter['tariff'] = inter['tariff'].to_f
          end

          inter
        end
    end

    mm_params
  end
end
