require 'rails_helper'

RSpec.describe Network::ElectricVehicle do
  let(:tech) { network_technology(build(:installed_ev, profile: profile, storage: 3.0)) }

  context 'in frame 0' do
    let(:profile) { nil }

    it 'has no production' do
      expect(tech.production_at(0)).to be_zero
    end

    it 'has no mandatory consumption' do
      expect(tech.mandatory_consumption_at(0)).to be_zero
    end

    it 'has conditional consumption equal to the storage amount' do
      expect(tech.conditional_consumption_at(0)).to eq(3.0)
    end
  end # in frame 0

  context 'with stored energy 0.5' do
    before { tech.stored[0] = 0.5 }

    context 'and a profile value of zero' do
      let(:profile) { [0.0, 0.0] }

      it 'has production of 0.5' do
        expect(tech.production_at(1)).to eq(0.5)
      end

      it 'has no mandatory consumption' do
        expect(tech.conditional_consumption_at(1)).to eq(3.0)
      end

      it 'has conditional consumption of 3.0' do
        expect(tech.conditional_consumption_at(1)).to eq(3.0)
      end
    end # and a profile value of zero

    context 'and a profile value of 1.0' do
      let(:profile) { [0.0, 1.0] }

      it 'has production of 0.5' do
        expect(tech.production_at(1)).to eq(0.5)
      end

      it 'has mandatory consumption of 1.0' do
        expect(tech.mandatory_consumption_at(1)).to eq(1.0)
      end

      it 'has conditional consumption of 2.0' do
        expect(tech.conditional_consumption_at(1)).to eq(2.0)
      end
    end # and a profile value of 1.0

    context 'with a value of -1' do
      let(:profile) { [0.0, -1.0] }

      it 'has production of zero' do
        expect(tech.production_at(1)).to be_zero
      end

      it 'has no mandatory consumption' do
        expect(tech.mandatory_consumption_at(1)).to be_zero
      end

      it 'has no conditional consumption' do
        expect(tech.conditional_consumption_at(1)).to be_zero
      end
    end # with stored energy of 0.5, and with a profile 1.0
  end # with a profile

  context 'when the previous frame was a disconnection' do
    let(:profile) { [-1.0, 0.0] }

    it 'has no production' do
      expect(tech.production_at(1)).to be_zero
    end

    it 'has no mandatory consumption' do
      expect(tech.mandatory_consumption_at(1)).to be_zero
    end

    it 'has conditional consumption equal to the storage amount' do
      expect(tech.conditional_consumption_at(1)).to eq(3.0)
    end
  end # when the previous frame was a disconnection
end
