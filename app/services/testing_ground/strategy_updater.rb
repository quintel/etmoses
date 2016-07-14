class TestingGround::StrategyUpdater
  def initialize(testing_ground, params)
    @testing_ground = testing_ground
    @params = params
  end

  def update
    return true if @params[:strategies].empty?

    @testing_ground.selected_strategy.update_attributes(strategy_params) &&
      @testing_ground.touch(:cache_updated_at)
  end

  private

  def strategy_params
    @params.require(:strategies).permit(
      :battery_storage,
      :ev_capacity_constrained,
      :ev_excess_constrained,
      :ev_storage,
      :solar_power_to_heat,
      :solar_power_to_gas,
      :hp_capacity_constrained,
      :hhp_switch_to_gas,
      :postponing_base_load,
      :saving_base_load,
      :capping_solar_pv,
      :capping_fraction
    )
  end
end
