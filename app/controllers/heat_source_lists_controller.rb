class HeatSourceListsController < ApplicationController
  respond_to :js, only: :update

  before_filter :find_heat_source_list

  def update
    @heat_source_list.update_attributes(heat_source_list_attributes)
  end

  private

  def heat_source_list_attributes
    params.require(:heat_source_list).permit(:asset_list)
  end

  def find_heat_source_list
    @heat_source_list = HeatSourceList.find(params[:id])
    @testing_ground = @heat_source_list.testing_ground

    authorize @heat_source_list
  end
end
