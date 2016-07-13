require 'rails_helper'

RSpec.describe Export do
  let(:topology){ FactoryGirl.create(:topology) }
  let(:fake_technology_profile) {
    JSON.dump(fake_profile_data.group_by{|t| t['node']})
  }

  let(:testing_ground){
    FactoryGirl.create(:testing_ground,
      scenario_id: 2,
      topology: topology,
      technology_profile: fake_technology_profile)
  }

  let(:export) { Export.new(testing_ground) }

  describe "default export" do
    let(:fake_profile_data) {
      TechnologyDistributorData.load_file('solar_pv_and_ev_distribution_two_nodes_lv1_and_lv2')
    }

    before do
      stub_et_engine_scenario_inputs_request
      stub_et_engine_scenario_create_request
      stub_et_engine_scenario_update_request

      expect(export).to receive(:solar_panel_units_factor).and_return(2)
      expect(export).to receive(:number_of_households).at_least(1).times.and_return(2)
    end

    it "exports an export" do
      expect(export.export).to eq({"id" => 2})
    end

    it "marks an export as valid" do
      expect(export.valid?).to eq(true)
    end
  end

  describe "more units than households for a share group" do
    let(:fake_profile_data) {
      TechnologyDistributorData.load_file('exporting_share_groups')
    }

    before do
      stub_et_engine_scenario_inputs_request
      stub_et_engine_scenario_create_request
      stub_et_engine_scenario_update_request

      expect(export).to receive(:number_of_households).at_least(1).times.and_return(2)
    end

    it "marks an export as invalid" do
      expect(export.valid?).to eq(false)
    end

    it 'groups the exported technologies' do
      expect(export.grouped_inputs.keys).to eq([
        "heating_households"
      ])
    end

    it 'groups the exported technologies' do
      expect(export.grouped_inputs.values.flatten.size).to eq(2)
    end
  end
end
