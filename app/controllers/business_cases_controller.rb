class BusinessCasesController < ResourceController
  RESOURCE_ACTIONS = %i(update compare compare_with data render_summary show)

  respond_to :js, only: [:compare_with, :data, :create, :update, :render_summary,
                         :validate]

  respond_to :csv, only: [:show]

  before_filter :find_testing_ground, except: :validate
  before_filter :find_business_case, only: RESOURCE_ACTIONS
  before_filter :authorize_generic, except: RESOURCE_ACTIONS
  before_filter :clear_job, only: :data

  skip_before_filter :authenticate_user!, only: [:data, :render_summary, :validate]

  def data
    unless @business_case.job_id.present?
      task = BusinessCaseCalculatorJob.new(@testing_ground, params[:strategies])

      @business_case.update_attributes(
        job: Delayed::Job.enqueue(task),
        job_finished_at: nil
      )
    end

    render json: { pending: @business_case.job_finished_at.blank? }
  end

  def render_summary
    @business_case_summary =
      Finance::BusinessCaseSummary.new(@business_case).summarize
  end

  def update
    @business_case.update_attributes(business_case_params)
  end

  def show
    respond_to do |wants|
      wants.html
      wants.csv do
        presenter = Finance::BusinessCaseCSVPresenter.new(@business_case)

        presenter.headers.each { |key, value| headers[key] = value }
        render text: presenter.to_csv
      end
    end
  end

  def compare_with
    begin
      @comparing_testing_ground = TestingGround.find(params[:comparing_testing_ground_id])
      @business_case_rows = Finance::BusinessCaseComparator.new(
        @business_case, @comparing_testing_ground.business_case).compare
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Testing ground not found' }, status: :unprocessable_entity
    end
  end

  def validate
    @topology_template = TopologyTemplate.find(
      params[:business_case][:topology_template_id])

    @market_model_template = MarketModelTemplate.find(
      params[:business_case][:market_model_template_id])

    render json: {
      valid: Finance::BusinessCaseValidator.new(
        @topology_template, @market_model_template).valid?
    }
  end

  private

  def clear_job
    if params[:clear]
      @business_case.clear_job!
    end
  end

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
