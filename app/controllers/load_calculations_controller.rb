class LoadCalculationsController < ApplicationController
  before_filter :find_testing_ground

  def heat
    render json: {
      values: [
        { type: 'space_heating_demand', name: "Space heating demand", load: (1..673).to_a.map{|t| Math.sin(t / 20) } },
        { type: 'hot_water_demand', name: "Hot water demand", load: (1..673).to_a.map{|t| Math.sin(t / 10) } }
      ]
    }
  end

  private

  def find_testing_ground
    @testing_ground = TestingGround.find(params[:testing_ground_id])
    authorize @testing_ground
  end
end
