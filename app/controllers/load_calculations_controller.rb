class LoadCalculationsController < ApplicationController
  before_filter :find_testing_ground

  def heat
    render json: {}
  end

  private

  def find_testing_ground
    @testing_ground = TestingGround.find(params[:testing_ground_id])
    authorize @testing_ground
  end
end
