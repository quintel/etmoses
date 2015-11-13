require 'rails_helper'

RSpec.describe Network::Technologies::Composite do
  let(:profile)   { Network::DepletingCurve.from([1.0, 1.0, 1.0, 1.0]) }
  let(:installed) { FactoryGirl.build(:installed_heat_pump, capacity: 0.8) }

  let(:tech) do
    Network::Technologies::Composite.new(Float::INFINITY, profile).tap do |c|
      c.add(network_technology(installed))
      c.add(network_technology(installed))
    end
  end

  let(:component_one) { tech.techs.first }
  let(:component_two) { tech.techs.last }

  # --

  describe 'component one, receiving mandatory 0.2' do
    before { component_one.receive_mandatory(0, 0.2) }

    it 'subtracts the amount from the component_one profile' do
      expect(component_one.profile.at(0)).to eq(0.8)
    end

    it 'subtracts the amount from the component_two profile' do
      expect(component_two.profile.at(0)).to eq(0.8)
    end
  end

  describe 'component two, receiving 0.6 conditional' do
    before { component_one.store(0, 0.6) }

    it 'subtracts the amount from the profile' do
      expect(component_one.profile.at(0)).to eq(0.4)
    end

    it 'subtracts the amount from the component_two profile' do
      expect(component_two.profile.at(0)).to eq(0.4)
    end
  end

  describe 'storing 0.5 in component_one' do
    before { component_one.store(0, 0.5) }

    it 'also adds the storage amount to component_two' do
      expect(component_two.stored.at(0)).to eq(0.5)
    end
  end
end
