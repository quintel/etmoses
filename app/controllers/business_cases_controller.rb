class BusinessCasesController < ResourceController
  RESOURCE_ACTIONS = %i(show edit update compare compare_with data)

  respond_to :js, only: [:compare_with, :data]

  before_filter :find_testing_ground
  before_filter :find_business_case, only: RESOURCE_ACTIONS
  before_filter :authorize_generic, except: RESOURCE_ACTIONS

  def show
    @business_case_summary = Finance::BusinessCaseSummary.new(@business_case).summarize
  end

  def data
    @business_case = Finance::BusinessCaseCreator.new(@testing_ground).create
    @business_case_summary = Finance::BusinessCaseSummary.new(@business_case).summarize
  end

  def create
    @business_case = Finance::BusinessCaseCreator.new(@testing_ground).create

    redirect_to testing_ground_business_case_path(@testing_ground, @business_case)
  end

  def edit
  end

  def update
    @business_case.update_attributes(business_case_params)

    redirect_to testing_ground_business_case_path(@testing_ground, @business_case)
  end

  def compare_with
    begin
      testing_ground = TestingGround.find(params[:comparing_testing_ground_id])

      render json: Finance::BusinessCaseComparator.new(
        @business_case, testing_ground.business_case).compare
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Testing ground not found' }, status: :unprocessable_entity
    end
  end

  private

  def business_case_params
    params.require(:business_case).permit(:financials)
  end

  def find_testing_ground
    @testing_ground = TestingGround.find(params[:testing_ground_id])

    unless @testing_ground.market_model
      redirect_to testing_ground_path(@testing_ground)
    end
  end

  def find_business_case
    @business_case = BusinessCase.find(params[:id])
    authorize @business_case
  end
end
