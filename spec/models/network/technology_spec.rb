require 'rails_helper'

RSpec.describe Network::Technology do
  let(:installed) { InstalledTechnology.new(capacity: profile.first) }
  let(:tech)      { Network::Technology.build(installed, profile) }

  context 'with a positive capacity' do
    let(:profile) { [2.0] }

    it 'sets the capacity' do
      expect(tech.capacity).to eq(2.0)
    end

    it 'is not a supplier' do
      expect(tech).to_not be_supplier
    end

    it 'is a consumer' do
      expect(tech).to be_consumer
    end

    it 'is not storage' do
      expect(tech).to_not be_storage
    end

    it 'has no conditional consumption' do
      expect(tech.conditional_consumption_at(0)).to be_zero
    end

    it 'has reads mandatory consumption from the profile' do
      expect(tech.mandatory_consumption_at(0)).to eq(2.0)
    end

    it 'has no production' do
      expect(tech.production_at(0)).to be_zero
    end
  end # with a positive load

  context 'with a negative capacity' do
    let(:profile) { [-2.0] }

    it 'sets the capacity' do
      expect(tech.capacity).to eq(-2.0)
    end

    it 'is a supplier' do
      expect(tech).to be_supplier
    end

    it 'is not a consumer' do
      expect(tech).to_not be_consumer
    end

    it 'is not storage' do
      expect(tech).to_not be_storage
    end

    it 'has no conditional consumption' do
      expect(tech.conditional_consumption_at(0)).to be_zero
    end

    it 'has no mandatory consumption' do
      expect(tech.mandatory_consumption_at(0)).to be_zero
    end

    it 'has reads production from the profile' do
      expect(tech.production_at(0)).to eq(2.0)
    end
  end # with a negative load

  context 'given a "load" instead of capacity' do
    let(:installed) { InstalledTechnology.new(load: profile.first) }
    let(:profile)   { [2.0] }

    it 'uses the load in place of capacity' do
      expect(tech.capacity).to eq(2.0)
    end
  end # given a "load" instead of capacity

  context 'given no "load" or capacity' do
    let(:installed) { InstalledTechnology.new }
    let(:profile)   { [2.0] }

    it 'has a capacity of zero' do
      expect(tech.capacity).to be_zero
    end
  end # given no "load" or capacity
end
