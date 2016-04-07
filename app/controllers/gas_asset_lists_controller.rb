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
        .where_pressure(part[:pressure_level])
        .map(&:attributes)
    end)
  end

  def calculate_net_present_value
    render json: GasAssetLists::NetPresentValueCalculator.new(@gas_asset_list).calculate
  end

  def calculate_cumulative_investment
    render json: GasAssetLists::CumulativeInvestmentCalculator.new(@gas_asset_list).calculate
  end

  private

  def gas_asset_list_attributes
    params.require(:gas_asset_list).permit(:asset_list)
  end

  def find_gas_asset_list
    @gas_asset_list = GasAssetList.find(params[:id])
    authorize @gas_asset_list
  end
end
