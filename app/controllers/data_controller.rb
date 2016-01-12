class DataController < ApplicationController
  respond_to :csv

  before_filter :find_testing_ground
  before_filter :set_csv_headers

  skip_before_filter :verify_authenticity_token

  def price_curve
    @merit_curve = merit_order.price_curve
  end

  def load_curves
    @merit_curve = merit_order.load_curves
  end

  def electricity_storage
    # Electricity storage requires individual technology loads; therefore we
    # cannot use the cache which only contains node-level loads.
    networks = @testing_ground.to_calculated_graphs(
      @testing_ground.selected_strategy.attributes
    )

    respond_with @summary = TestingGround::StorageSummary.new(
      networks.detect { |net| net.carrier == :electricity }
    )
  end

  private

  def calculator
    @calculator ||= TestingGround::Calculator.new(
      @testing_ground,
      strategies: @testing_ground.selected_strategy.attributes,
      resolution: :high
    )
  end

  def merit_order
    Market::MeritCurveBuilder.new(
      @testing_ground, calculator.network(:electricity)
    ).merit
  end

  def set_csv_headers
    name = [params[:action], @testing_ground.id, 'csv'].join('.')

    headers['Content-Disposition'] = "attachment; filename=\"#{name}\""
    headers['Content-Type'] ||= 'text/csv'
  end

  def find_testing_ground
    @testing_ground = TestingGround.find(params[:testing_ground_id])
    session[:testing_ground_id] = params[:testing_ground_id]

    authorize @testing_ground
  end
end
