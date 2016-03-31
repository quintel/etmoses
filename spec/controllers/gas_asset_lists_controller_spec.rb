require 'rails_helper'

RSpec.describe GasAssetListsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:testing_ground) { FactoryGirl.create(:testing_ground, user: user) }
  let!(:sign_in_user) { sign_in(user) }

  describe "editing an existing gas list" do
    let(:gas_asset_list) { FactoryGirl.create(:gas_asset_list, testing_ground: testing_ground) }
    let(:asset_list) {
      [
        { "pressure_level"=>"0.1",
          "part"=>"connectors",
          "type"=>"ye_olde_connector",
          "amount"=>"1",
          "stakeholder"=>"cooperation",
          "building_year"=>"1960" },
        { "pressure_level"=>"0.1",
          "part"=>"pipes",
          "type"=>"magic_pipe",
          "amount"=>"1",
          "stakeholder"=>"cooperation",
          "building_year"=>"1960" }
      ]
    }

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
                         { part: 'pipes', pressure_level: 0.1 },
                         { part: 'pipes', pressure_level: 1.0 }
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
end
