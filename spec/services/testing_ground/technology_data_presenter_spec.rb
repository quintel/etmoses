require 'rails_helper'

RSpec.describe TestingGround::TechnologyDataPresenter do
  let(:technology) {
    InstalledTechnology.new(
        key: 'households_water_heater_hybrid_heatpump_air_water_electricity',
        components: [
          { type: 'households_water_heater_hybrid_heatpump_air_water_electricity_electricity',
            capacity: 5.0 },
          { type: 'households_space_heater_hybrid_heatpump_air_water_electricity_gas',
            capacity: 1.0 }
        ]
    )
  }

  let(:presenter) {
    TestingGround::TechnologyDataPresenter.new(technology, 'LV1')
  }

  it 'presents data' do
    expect(presenter.present.fetch('households_water_heater_hybrid_heatpump_air_water_electricity_electricity_capacity')).to eq("5.0")
  end
end
