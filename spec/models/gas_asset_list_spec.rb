require 'rails_helper'

RSpec.describe GasAssetList do
  it "creates an empty asset list" do
    gas_asset_list = GasAssetList.create!(asset_list: [])

    expect(gas_asset_list.asset_list).to eq([])
  end

  it "creates an asset list with one asset" do
    gas_asset_list = GasAssetList.create!(asset_list: [
      { part: 'tube',
        type: 'test_type',
        amount: 5,
        stakeholder: "system_operator",
        building_year: "1970" }
    ])

    expect(gas_asset_list.asset_list).to eq([{
      "part"=>"tube", "type"=>"test_type", "amount"=>5,
      "stakeholder"=>"system_operator", "building_year"=>"1970"
    }])
  end
end
