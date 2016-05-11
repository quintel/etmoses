require 'rails_helper'

RSpec.describe GasAssetLists::AssetListGenerator do
  let(:testing_ground) {
    FactoryGirl.create(:testing_ground,
        technology_profile: YAML.load(File.read("#{ Rails.root }/spec/fixtures/data/technology_profiles/gas_technologies.yml")))
  }

  it "generates a list of gas asset" do
    asset_list = GasAssetLists::AssetListGenerator.new(testing_ground)

    expect(asset_list.generate).to_not be_blank
  end
end
