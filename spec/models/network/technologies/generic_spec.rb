require 'rails_helper'

RSpec.describe Network::Technologies::Generic do
  let(:attrs) { {} }

  let(:installed) do
    InstalledTechnology.new({ capacity: profile.first }.merge(attrs))
  end

  let(:tech) do
    Network::Technologies.from_installed(installed, profile, strategies: {})
  end

  context 'with a positive capacity' do
    let(:profile) { [2.0] }

    it 'sets the capacity' do
      expect(tech.capacity).to eq(2.0)
    end

    it 'is not a producer' do
      expect(tech).to_not be_producer
    end

    it 'is a consumer' do
      expect(tech).to be_consumer
    end

    it 'is not storage' do
      expect(tech).to_not be_storage
    end

    it 'has no conditional consumption' do
      expect(tech.conditional_consumption_at(0, nil)).to be_zero
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

    it 'is a producer' do
      expect(tech).to be_producer
    end

    it 'is not a consumer' do
      expect(tech).to_not be_consumer
    end

    it 'is not storage' do
      expect(tech).to_not be_storage
    end

    it 'has no conditional consumption' do
      expect(tech.conditional_consumption_at(0, nil)).to be_zero
    end

    it 'has no mandatory consumption' do
      expect(tech.mandatory_consumption_at(0)).to be_zero
    end

    it 'has reads production from the profile' do
      expect(tech.production_at(0)).to eq(2.0)
    end
  end # with a negative load

  context 'given no capacity' do
    let(:installed) { InstalledTechnology.new }
    let(:profile)   { [2.0] }

    it 'has a capacity of zero' do
      expect(tech.capacity).to be_zero
    end
  end # given no capacity

  context 'with a positive demand' do
    let(:profile) { [4.0] }
    let(:attrs) { { demand: 4.0, capacity: nil } }

    it 'is not a producer' do
      expect(tech).to_not be_producer
    end

    it 'is a consumer' do
      expect(tech).to be_consumer
    end

    it 'is not storage' do
      expect(tech).to_not be_storage
    end

    it 'has no conditional consumption' do
      expect(tech.conditional_consumption_at(0, nil)).to be_zero
    end

    it 'reads mandatory consumption from the profile' do
      expect(tech.mandatory_consumption_at(0)).to eq(4.0)
    end

    it 'has has no production' do
      expect(tech.production_at(0)).to be_zero
    end
  end # with a positive demand

  context 'with a negative demand' do
    let(:profile) { [-4.0] }
    let(:attrs) { { demand: -4.0, capacity: nil } }

    it 'is a producer' do
      expect(tech).to be_producer
    end

    it 'is not a consumer' do
      expect(tech).to_not be_consumer
    end

    it 'is not storage' do
      expect(tech).to_not be_storage
    end

    it 'has no conditional consumption' do
      expect(tech.conditional_consumption_at(0, nil)).to be_zero
    end

    it 'has no mandatory consumption' do
      expect(tech.mandatory_consumption_at(0)).to be_zero
    end

    it 'reads production from the profile' do
      expect(tech.production_at(0)).to eq(4.0)
    end
  end # with a positive demand
end
