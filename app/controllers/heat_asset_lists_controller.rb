class HeatAssetListsController < ApplicationController
  respond_to :js, only: %i(update reload_heat_asset_list)

  before_filter :find_heat_asset_list

  def update
    @heat_asset_list.update_attributes(heat_asset_list_attributes)
    @testing_ground.business_case.clear_job!
  end

  # POST /testing_grounds/:testing_ground_id/heat_asset_lists/:id/reload_heat_asset_list
  def reload_heat_asset_list
    HeatAssetLists::AssetListUpdater.new(@testing_ground).update!
  end

  private

  def heat_asset_list_attributes
    params.require(:heat_asset_list).permit(:asset_list)
  end

  def find_heat_asset_list
    @heat_asset_list = HeatAssetList.find(params[:id])
    @testing_ground = @heat_asset_list.testing_ground

    authorize @heat_asset_list
  end
end
