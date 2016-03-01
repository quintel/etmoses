require 'rails_helper'

RSpec.describe Network::Technologies::Composite do
  let(:profile)   { Network::Curve.from([1.0, 1.0, 1.0, 1.0]) }
  let(:capacity)  { Float::INFINITY }

  let(:installed_one) do
    FactoryGirl.build(:installed_heat_pump, buffer: 'a', capacity: 0.8)
  end

  let(:installed_two) do
    FactoryGirl.build(:installed_heat_pump, buffer: 'a', capacity: 0.8)
  end

  let(:tech) do
    comp = Network::Technologies::Composite.new(
      capacity, Float::INFINITY, profile
    )

    comp.add(network_technology(installed_one))
    comp.add(network_technology(installed_two))

    comp
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

  context 'with a boosting technology' do
    let(:installed_two) do
      FactoryGirl.build(
        :installed_heat_pump, buffer: 'a',
        capacity: 0.8, position_relative_to_buffer: 'boosting'
      )
    end

    context 'with sufficient production' do
      let(:profile) { Network::Curve.from([0.5, 0.5, 0.5, 0.5]) }

      it 'runs with buffering technologies' do
        expect(component_one.mandatory_consumption_at(0)).to eq(0.5)
      end

      it 'does not run boosting technologies' do
        component_one.receive_mandatory(0, 0.5)
        expect(component_two.mandatory_consumption_at(0)).to be_zero
      end
    end

    context 'with insufficient production' do
      let(:profile) { Network::Curve.from([1.0, 1.0, 1.0, 1.0]) }

      it 'runs with buffering technologies' do
        expect(component_one.mandatory_consumption_at(0)).to eq(0.8)
      end

      it 'does not run boosting technologies' do
        component_one.receive_mandatory(0, 0.8)

        expect(component_two.mandatory_consumption_at(0))
          .to be_within(1e-4).of(0.2)
      end
    end

    context 'with insufficient composite capacity' do
      let(:capacity) { 0.1 }

      it 'limits buffering consumption to the comp. capacity' do
        expect(component_one.mandatory_consumption_at(0)).to eq(0.1)
      end

      it 'turns on boosting technologies' do
        component_one.receive_mandatory(0, 0.8)

        expect(component_two.mandatory_consumption_at(0)).
          to be_within(1e-5).of(0.2)
      end

      context 'with energy stored in the reserve' do
        let(:capacity) { 0.4 }
        let(:profile)  { Network::Curve.from([1.5, 1.5, 1.5, 1.5]) }

        before do
          tech.reserve.add(0, 1.0)
        end

        it 'depletes by the capacity of the composite' do
          expect(tech.reserve.at(1)).to eq(0.6)
        end

        it 'runs with buffering technologies' do
          expect(component_one.mandatory_consumption_at(1)).to eq(0.4)
        end

        it 'turns on boosting technologies' do
          component_one.receive_mandatory(1, 0.8)

          expect(component_two.mandatory_consumption_at(1)).
            to be_within(1e-5).of(0.3)
        end
      end # with energy stored in the reserve
    end # with insufficient composite capacity
  end # with a boosting technology
end
