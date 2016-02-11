require 'rails_helper'

RSpec.describe Export do
  let(:topology){ FactoryGirl.create(:topology) }
  let(:fake_technology_profile) {
    fake_profile_data = TechnologyDistributorData.load_file('solar_pv_and_ev_distribution_two_nodes_lv1_and_lv2')

    JSON.dump(fake_profile_data.group_by{|t| t['node']})
  }

  let(:testing_ground){
    FactoryGirl.create(:testing_ground,
      scenario_id: 2,
      topology: topology,
      technology_profile: fake_technology_profile)
  }

  it "exports an export" do
    export = Export.new(testing_ground)

    stub_et_engine_scenario_inputs_request
    stub_et_engine_scenario_create_request
    stub_et_engine_scenario_update_request

    expect(export).to receive(:solar_panel_units_factor).and_return(2)
    expect(export).to receive(:number_of_households).twice.and_return(2)

    expect(export.export).to eq({"id" => 2})
  end
end
