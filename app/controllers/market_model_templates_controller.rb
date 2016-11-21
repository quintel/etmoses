class MarketModelTemplatesController < ResourceController
  RESOURCE_ACTIONS = %i(show edit update destroy clone)

  respond_to :html
  respond_to :js, only: :clone

  before_filter :find_market_model, only: RESOURCE_ACTIONS
  before_filter :authorize_generic, except: RESOURCE_ACTIONS
  before_filter :fetch_testing_ground, only: :clone

  skip_before_filter :authenticate_user!, only: [:show, :index]

  def index
    @market_model_templates = policy_scope(MarketModelTemplate)
  end

  def new
    @market_model_template = current_user.market_model_templates.new(interactions: MarketModelTemplate::DEFAULT_INTERACTIONS)
  end

  def create
    respond_with(@market_model_template =
      current_user.market_model_templates.create(market_model_template_params))
  end

  def show
  end

  def edit
  end

  def update
    if @market_model_template.update_attributes(market_model_template_params)
      redirect_to market_model_template_path(@market_model_template)
    else
      render :edit
    end
  end

  def destroy
    @market_model_template.destroy

    redirect_to(market_model_templates_path)
  end

  # POST /market_model_templates/:id/clone
  def clone
    @clone = @market_model_template.dup

    if @clone.update_attributes(market_model_template_params)
      render json: { redirect: market_model_template_path(@clone) }
    else
      render json: { errors: @clone.errors }, status: 422
    end
  end

  private

  def find_market_model
    @market_model_template = MarketModelTemplate.find(params[:id])
    authorize(@market_model_template)
  end

  def market_model_template_params
    mm_params = params.require(:market_model_template)
      .permit(policy(:market_model_template).permitted_attributes)

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
