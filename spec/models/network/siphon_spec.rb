require 'rails_helper'

RSpec.describe Network::Siphon do
  context 'with a capacity of 10' do
    let(:tech) do
      network_technology(build(:installed_p2g, capacity: 10.0))
    end

    it 'has no production' do
      expect(tech.production_at(1)).to be_zero
    end

    it 'has no mandatory consumption' do
      expect(tech.mandatory_consumption_at(1)).to be_zero
    end

    it 'has conditional consumption equal to the capacity' do
      expect(tech.conditional_consumption_at(1)).to eq(10.0)
    end
  end # with a capacity of 10

  context 'when disabled' do
    let(:tech) do
      network_technology(
        build(:installed_p2g, capacity: 10.0), 2, solar_storage: 'false')
    end

    it 'should be a Null' do
      expect(tech).to be_a(Network::Null)
    end

    it 'has no production' do
      expect(tech.production_at(0)).to be_zero
    end

    it 'has no mandatory consumption' do
      expect(tech.mandatory_consumption_at(0)).to be_zero
    end

    it 'has no conditional consumption' do
      expect(tech.conditional_consumption_at(0)).to be_zero
    end
  end # when disabled
end # Network::Siphon
