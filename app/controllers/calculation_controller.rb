class CalculationController < ApplicationController
  skip_before_filter :authenticate_user!

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

  def gas_level_summary
    with_cached_networks(:low) do |calc, _|
      gas    = calc.network(:gas)
      assets = GasAssetListDecorator.new(testing_ground.gas_asset_list).decorate
      levels = Network::Builders::GasChain.build(gas, assets)

      render json: GasAssetLists::NetworkSummary.new(levels)
    end
  end

  private

  def with_cached_networks(resolution = :high)
    calculator = calculator(resolution)
    result = calculator.calculate

    if result[:pending]
      render json: result
    else
      yield(calculator, result)
    end
  rescue StandardError => ex
    notify_airbrake(ex) if defined?(Airbrake)

    result =
      if ex.class == TestingGround::DataError
        { error: ex.message }
      else
        { error: I18n.t("testing_grounds.error.data") }
      end


    if Rails.env.development? || Rails.env.test?
      result[:message]   = "#{ ex.class }: #{ ex.message }"
      result[:backtrace] = ex.backtrace

      Rails.logger.debug(ex.message)
      Rails.logger.debug(ex.backtrace.join("\n"))
    end

    render json: result, status: 500
  end

  def calculator(resolution = :high)
    TestingGround::Calculator.new(
      testing_ground, calculation_options.merge(
        strategies:  testing_ground.selected_strategy.attributes,
        resolution:  resolution
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
