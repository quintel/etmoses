class Import
  class ElectricVehicleBuilder < BaseBuilder
    EV_KEY = 'transport_car_using_electricity'

    def build(response)
      if transport_car = response.detect { |tech| tech['type'] == EV_KEY }
        [ transport_car.merge(initial_investment) ]
      else
        []
      end
    end

    private

    def initial_investment
      { 'initial_investment' =>
          @gqueries.fetch('electric_cars_additional_costs').fetch('present') }
    end
  end
end
