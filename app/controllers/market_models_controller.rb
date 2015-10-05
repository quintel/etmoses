class MarketModelsController < ResourceController
  RESOURCE_ACTIONS = %i(show edit update destroy clone)

  respond_to :js, only: :clone

  before_filter :find_market_model, only: RESOURCE_ACTIONS
  before_filter :authorize_generic, except: RESOURCE_ACTIONS
  before_filter :fetch_testing_ground, only: :clone

  skip_before_filter :authenticate_user!, only: [:show, :index]

  def index
    @market_models = policy_scope(MarketModel).order(:name)
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

  # POST /market_models/:id/clone
  def clone
    cloner = TestingGround::Cloner.new(@testing_ground, @market_model, market_model_params)
    cloner.clone

    @errors = cloner.errors
  end

  def destroy
    if TestingGround.where(market_model: @market_model).count > 0
      @market_model.update_attribute(:user, User.orphan)
    else
      @market_model.destroy
    end

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
