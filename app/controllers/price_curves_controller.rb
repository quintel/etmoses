class PriceCurvesController < ResourceController
  RESOURCE_ACTIONS = %i(show edit update destroy)

  before_filter :fetch_profile, only: RESOURCE_ACTIONS
  before_filter :authorize_generic, except: RESOURCE_ACTIONS

  respond_to :html
  respond_to :json, only: :show

  def new
    @price_curve = PriceCurve.new
  end

  def create
    @price_curve = current_user.price_curves.create(profile_params)

    respond_with(@price_curve)
  end

  def show
    respond_with(@price_curve)
  end

  def edit
  end

  def update
    if @price_curve.update_attributes(profile_params)
      redirect_to price_curve_path(@price_curve)
    else
      render :edit
    end
  end

  def destroy
    @price_curve.destroy

    redirect_to(load_profiles_path)
  end

  private

  def authorize_generic
    authorize PriceCurve
  end

  def fetch_profile
    @price_curve = PriceCurve.find(params[:id])
    authorize @price_curve
  end

  def profile_params
    params.require(:price_curve).permit(:key, :name, :curve, :public)
  end
end
