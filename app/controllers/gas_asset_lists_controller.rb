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

  def fake_gas_load
    render json: {
      name: 'Gas load chart',
      values: [
        { name: '40 bar', type: 'gas_high', load: 365.times.map{|_| rand } },
        { name: '8 bar',  type: 'gas_medium', load: 365.times.map{|_| rand } },
        { name: '4 bar',  type: 'gas_medium_low', load: 365.times.map{|_| rand } }
      ]
    }
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

  def load_summary
    gas_network = calculated_gas_network
    assets      = GasAssetListDecorator.new(@gas_asset_list).decorate
    levels      = Network::Builders::GasChain.build(gas_network, assets)

    render json: localize_summary(GasAssetLists::NetworkSummary.new(levels))
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

  # Internal: Receives a gas NetworkSummary and translates the load fields for
  # each layer into a human-readable label.
  #
  # Returns an Array[Hash].
  def localize_summary(summary)
    summary.as_json.map do |row|
      translated = row.dup

      translated[:stacked] =
        row[:stacked].each_with_object({}) do |(key, data), fields|
          fields[I18n.t("gas_summary.#{key}")] = data
        end

      translated
    end
  end

  def calculated_gas_network
    @testing_ground.to_calculated_graphs(
      range: 0...36040,
      strategies: @testing_ground.selected_strategy.attributes
    ).detect { |net| net.carrier == :gas }
  end
end
