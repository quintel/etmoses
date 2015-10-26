class MeritController < ApplicationController
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

  private

  def merit_order
    graph = TestingGround::Calculator.new(@testing_ground,
              @testing_ground.selected_strategy.attributes).calculate

    network = TreeToGraph.convert(graph[:graph])

    Market::MeritCurveBuilder.new(@testing_ground, network).merit
  end

  def set_csv_headers
    headers['Content-Disposition'] = "attachment; filename=\"#{params[:action]}.csv\""
    headers['Content-Type'] ||= 'text/csv'
  end

  def find_testing_ground
    @testing_ground = TestingGround.find(params[:testing_ground_id])
    session[:testing_ground_id] = params[:testing_ground_id]
    authorize @testing_ground
  end
end
