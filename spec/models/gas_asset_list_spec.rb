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
        units: 5,
        stakeholder: "system_operator",
        building_year: "1970" }
    ])

    expect(gas_asset_list.asset_list).to eq([{
      part: "tube", type: "test_type", units: 5,
      stakeholder: "system_operator", building_year: "1970"
    }])
  end

  describe "creating a default asset list" do
    it "creates a default asset list based on the contents of the testing ground" do
      testing_ground = FactoryGirl.create(:testing_ground,
        technology_profile: YAML.load(File.read("#{ Rails.root }/spec/fixtures/data/technology_profiles/gas_technologies.yml")))

      gas_asset_list = FactoryGirl.create(:gas_asset_list,
        testing_ground: testing_ground)

      expect(gas_asset_list.asset_list).to eq([])
    end
  end

  describe '#stakeholders' do
    context 'with no assets' do
      let(:list) do
        GasAssetList.new(asset_list: [])
      end

      it 'returns a set' do
        expect(list.stakeholders).to be_a(Set)
      end

      it 'is empty' do
        expect(list.stakeholders).to be_empty
      end
    end

    context 'with one asset, one stakeholder' do
      let(:list) do
        GasAssetList.new(asset_list: [{ stakeholder: 'one' }])
      end

      it 'returns a set' do
        expect(list.stakeholders).to be_a(Set)
      end

      it 'includes the stakeholder' do
        expect(list.stakeholders).to include('one')
      end
    end

    context 'with two assets, two stakeholders' do
      let(:list) do
        GasAssetList.new(asset_list: [
          { stakeholder: 'one' },
          { stakeholder: 'two' },
        ])
      end

      it 'returns a set' do
        expect(list.stakeholders).to be_a(Set)
      end

      it 'includes both stakeholders' do
        expect(list.stakeholders.to_a).to eq(%w( one two ))
      end
    end
  end # stakeholders
end
