class CalculationController < ApplicationController
  # GET /testing_grounds/:id/calculation/heat
  def heat
    calculator = TestingGround::Calculator.new(
      testing_ground, calculation_options.merge(
        strategies:  testing_ground.selected_strategy.attributes,
        resolution:  :high
      )
    )

    render json: TestingGround::HeatSummary.new(calculator)
  end

  private

  def testing_ground
    @testing_ground ||=
      TestingGround.find(params[:id]).tap { |les| authorize(les) }
  end

  def calculation_options
    return { range_start: 0, range_end: 672 }

    params.require(:calculation).permit([
      :range_start, :range_end,
      :resolution,
      :strategies
    ])
  end
end
