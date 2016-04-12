class GasAssetListsController < ResourceController
  respond_to :js, only: :update

  before_filter :find_gas_asset_list, except: :get_types
  before_filter :authorize_generic, only: :get_types

  def update
    @gas_asset_list.update_attributes(gas_asset_list_attributes)
  end

  def get_types
    render json: (params.fetch(:gas_parts).map do |part|
      DATA_SOURCES[part[:part]]
        .where_pressure(part[:pressure_level_index])
        .map(&:attributes)
    end)
  end

  def reload_gas_asset_list
    render json: GasAssetLists::AssetListGenerator
      .new(@gas_asset_list.testing_ground).generate
  end

  def calculate_net_present_value
    render json: GasAssetLists::NetPresentValueCalculator
      .new(@gas_asset_list).calculate
  end

  def calculate_cumulative_investment
    render json: GasAssetLists::CumulativeInvestmentCalculator
      .new(@gas_asset_list).calculate
  end

  def fake_stacked_bar
    render json: [
      { pressure_level: 'End-points <-> 0.125',  stacked: { loss: -1, feed_in: -2, consumption: 1 } },
      { pressure_level: '0.125 <-> 4.0',  stacked: { loss: -0.2, feed_in: -3.2, consumption: 2 } },
      { pressure_level: '4.0 <-> 8.0',  stacked: { loss: -1.2, feed_in: -1, consumption: 1 } },
      { pressure_level: '8.0 <-> 40.0', stacked: { loss: -0.5, feed_in: -2, consumption: 2 } }
    ]
  end

  private

  def gas_asset_list_attributes
    params.require(:gas_asset_list).permit(:asset_list)
  end

  def find_gas_asset_list
    @gas_asset_list = GasAssetList.find(params[:id])
    @testing_ground = @gas_asset_list.testing_ground

    authorize @gas_asset_list
  end
end
