require 'rails_helper'

RSpec.describe GasAssetListsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:testing_ground) { FactoryGirl.create(:testing_ground, user: user) }
  let!(:sign_in_user) { sign_in(user) }
  let(:asset_list) {
    [
      { "pressure_level_index"=>"0",
        "part"=>"connectors",
        "type"=>"big_connector",
        "amount"=>"1",
        "stakeholder"=>"cooperation",
        "building_year"=>"1980" },
      { "pressure_level_index"=>"0",
        "part"=>"pipes",
        "type"=>"big_pipe",
        "amount"=>"1",
        "stakeholder"=>"cooperation",
        "building_year"=>"1960" }
    ]
  }

  describe "editing an existing gas list" do
    let(:gas_asset_list) { FactoryGirl.create(:gas_asset_list, testing_ground: testing_ground) }
    it "updates an gas asset list" do
      post :update, id: gas_asset_list.id,
                    testing_ground_id: testing_ground.id,
                    gas_asset_list: { asset_list: JSON.dump(asset_list) },
                    format: :js

      expect(gas_asset_list.reload.asset_list).to eq(asset_list)
    end
  end

  describe "get types" do
    it "asking the server for multiple gas parts" do
      post :get_types, testing_ground_id: testing_ground.id,
                       format: :json,
                       gas_parts: [
                         { part: 'pipes', pressure_level_index: 0 },
                         { part: 'pipes', pressure_level_index: 0 }
                       ]

      expect(JSON.parse(response.body)).to_not be_blank
    end

    it "asking the server for a certain gas part" do
      post :get_types, testing_ground_id: testing_ground.id,
                       gas_parts: [{
                         part: 'pipes',
                         pressure_level: 0.1
                       }],
                       format: :json

      expect(JSON.parse(response.body)).to_not be_blank
    end
  end

  describe "calculations" do
    let(:gas_asset_list) {
      FactoryGirl.create(:gas_asset_list,
        testing_ground: testing_ground,
        asset_list: asset_list)
    }

    it "calculates net present values" do
      post :calculate_net_present_value,
        testing_ground_id: testing_ground.id,
        id: gas_asset_list.id

      expect(JSON.parse(response.body).slice("1960", "2010")).to eq({
        "1960" => 500.0, "2010" => 40.0
      })
    end

    it "calculates cumulative investments" do
      post :calculate_cumulative_investment,
        testing_ground_id: testing_ground.id,
        id: gas_asset_list.id

      expect(JSON.parse(response.body).slice("2010", "2030")).to eq({
        "2010" => 500.0, "2030" => 600.0
      })
    end
  end

  describe "reload gas asset list" do
    let(:gas_asset_list) {
      FactoryGirl.create(:gas_asset_list,
        testing_ground: testing_ground,
        asset_list: asset_list)
    }

    let!(:stub_total_number_of_households) {
      expect_any_instance_of(GasAssetLists::AssetListGenerator).to(
        receive(:total_number_of_households).at_least(:once).and_return(1))
    }

    it "reloads existing gas asset list" do
      post :reload_gas_asset_list,
        testing_ground_id: testing_ground.id,
        id: gas_asset_list.id

      expect(JSON.parse(response.body)).to_not be_blank
    end
  end
end
