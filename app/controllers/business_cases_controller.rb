class BusinessCasesController < ResourceController
  RESOURCE_ACTIONS = %i(show edit update)

  before_filter :find_testing_ground
  before_filter :find_business_case, only: RESOURCE_ACTIONS
  before_filter :authorize_generic, except: RESOURCE_ACTIONS

  def show
    @business_case_calculator = Finance::BusinessCaseCalculator.new(@business_case)
  end

  def create
    @business_case = BusinessCase.find_or_create_by(testing_ground: @testing_ground)

    redirect_to testing_ground_business_case_path(@testing_ground, @business_case)
  end

  def edit
    @business_case = Finance::BusinessCaseCalculator.new(@business_case)
  end

  def update
    @business_case.update_attributes(business_case_params)

    redirect_to testing_ground_business_case_path(@testing_ground, @business_case)
  end

  private

  def business_case_params
    params.require(:business_case).permit(:financials)
  end

  def find_testing_ground
    @testing_ground = TestingGround.find(params[:testing_ground_id])
  end

  def find_business_case
    @business_case = BusinessCase.find(params[:id])
    authorize @business_case
  end
end
