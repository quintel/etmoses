require 'rails_helper'

RSpec.describe TestingGround::TechnologyBuilder do
  it "creates a technology" do
    technology = TestingGround::TechnologyBuilder.new({
      key: "base_load",
      scenario_id: 1,
      load_profiles: nil,
      buffer: nil
    })

    expect(technology.build).to be_an_instance_of(InstalledTechnology)
  end

  describe "creates a composite" do
    let(:technology) {
      TestingGround::TechnologyBuilder.new({
        key: "buffer_space_heating",
        composite_index: 5,
        scenario_id: 1,
        load_profiles: nil,
        buffer: nil
      }).build
    }

    it "is a composite" do
      expect(technology.composite).to eq(true)
    end
  end

  describe "creates a hhp" do
    let(:builder) {
      TestingGround::TechnologyBuilder.new({
        key: "households_water_heater_hybrid_heatpump_air_water_electricity",
        scenario_id: 1,
        load_profiles: nil,
        buffer: nil
      })
    }

    let(:technology) {
      builder.build
    }

    let!(:mock_stats) {
      expect(builder).to receive(:et_engine_stats).at_least(:once).and_return({
        'households_water_heater_hybrid_heatpump_air_water_electricity' => {}
      })
    }

    it "is a hybrid" do
      expect(technology.carrier).to eq(:hybrid)
    end

    it "has components" do
      expect(technology.components.size).to eq(2)
    end
  end
end
