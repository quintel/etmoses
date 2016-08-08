require 'rails_helper'

RSpec.describe Market::InitialCosts do
  let(:network)  { Network::Builders::Electricity.build(tree) }
  let(:networks) { { electricity: network } }
  let(:testing_ground) { FactoryGirl.create(:testing_ground) }

  let(:gas_asset_list) {
    FactoryGirl.create(:gas_asset_list, testing_ground: testing_ground)
  }

  let(:heat_source_list) {
    FactoryGirl.create(:heat_source_list, testing_ground: testing_ground)
  }

  let(:initial_costs) {
    Market::InitialCosts.new(networks, testing_ground).calculate
  }

  describe "calculates the initial costs" do
    let(:tree){
      {
        "name"               => "A node",
        "stakeholder"        => "system operator",
        "technical_lifetime" => 1,
        "investment_cost"    => 50
      }
    }

    it "calculates" do
      expect(initial_costs).to eq({ "system operator" => 50.0 })
    end
  end

  describe "it takes units into account" do
    let(:tree){
      {
        "name"               => "A node",
        "stakeholder"        => "system operator",
        "technical_lifetime" => 1,
        "investment_cost"    => 50,
        "units"              => 2
      }
    }

    it "calculates" do
      expect(initial_costs).to eq({ "system operator" => 100.0 })
    end
  end
end
