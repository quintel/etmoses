require 'rails_helper'

RSpec.describe TestingGround::TechnologyBuilder do
  it "creates a technology" do
    technology = TestingGround::TechnologyBuilder.new({
      key: "base_load",
      scenario_id: 1,
      load_profiles: nil
    })

    expect(technology.build).to be_an_instance_of(InstalledTechnology)
  end

  describe "creates a composite" do
    let(:technology) {
      TestingGround::TechnologyBuilder.new({
        key: "buffer_space_heating",
        composite_index: 5,
        scenario_id: 1,
        load_profiles: nil
      }).build
    }

    it "is a composite" do
      expect(technology.composite).to eq(true)
    end
  end
end
