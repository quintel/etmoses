class CalculationController < ApplicationController
  # POST /testing_grounds/:id/calculation/heat
  def heat
    render json: TestingGround::HeatSummary.new(calculator)
  end

  # POST /testing_grounds/:id/calculation/gas
  def gas
    gas_network = calculator.network(:gas)
    assets      = GasAssetListDecorator.new(testing_ground.gas_asset_list).decorate
    levels      = Network::Builders::GasChain.build(gas_network, assets)

    render json: GasAssetLists::LoadSummary.new(levels).as_json
  end

  private

  def calculator
    TestingGround::Calculator.new(
      testing_ground, calculation_options.merge(
        strategies:  testing_ground.selected_strategy.attributes,
        resolution:  :high
      )
    )
  end

  def testing_ground
    @testing_ground ||=
      TestingGround.find(params[:id]).tap { |les| authorize(les) }
  end

  def calculation_options
    params.require(:calculation).permit([
      :range_start, :range_end,
      :resolution,
      :strategies
    ])
  end
end
