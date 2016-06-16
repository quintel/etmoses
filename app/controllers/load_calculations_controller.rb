class LoadCalculationsController < ApplicationController
  before_filter :find_testing_ground

  def heat
    render json: {
      demand: {
        hot_water: fake_load,
        space_heating: fake_load
      },
      supply: {
        must_run: fake_load,
        dispatchable: fake_load
      },
      buffer_load: fake_load
    }
  end

  private

  def fake_load
    (0...673).to_a.map { |t| Math.sin(t / 50) }
  end

  def find_testing_ground
    @testing_ground = TestingGround.find(params[:testing_ground_id])
    authorize @testing_ground
  end
end
