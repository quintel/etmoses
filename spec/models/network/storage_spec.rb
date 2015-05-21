require 'rails_helper'

RSpec.describe Network::Storage do
  let(:capacity) { Float::INFINITY }

  let(:tech) do
    network_technology(build(
      :installed_battery, capacity: capacity, storage: 2.0
    ))
  end

  context 'in frame 0' do
    it 'is not a producer' do
      expect(tech).to_not be_producer
    end

    it 'is not a consumer' do
      expect(tech).to_not be_consumer
    end

    it 'is storage' do
      expect(tech).to be_storage
    end

    it 'has no production' do
      expect(tech.production_at(0)).to be_zero
    end

    it 'has no mandatory consumption' do
      expect(tech.mandatory_consumption_at(0)).to be_zero
    end

    it 'has conditional consumption equal to the storage amount' do
      expect(tech.conditional_consumption_at(0)).to eq(2.0)
    end
  end # in frame 0

  context 'in frame 1' do
    context 'with no storage carried from frame 0' do
      it 'has no production' do
        expect(tech.production_at(1)).to be_zero
      end

      it 'has conditional consumption equal to the storage amount' do
        expect(tech.conditional_consumption_at(1)).to eq(2.0)
      end
    end # with no storage carried from frame 0

    context 'with 1.5 storage carried from frame 0' do
      before { tech.stored[0] = 1.5 }

      it 'has production equal to the energy stored' do
        expect(tech.production_at(1)).to eq(1.5)
      end

      it 'has conditional consumption equal to the storage amount' do
        expect(tech.conditional_consumption_at(1)).to eq(2.0)
      end

      context 'with capacity of 0.2' do
        let(:capacity) { 0.2 }

        it 'has mandatory consumption equal to stored - capacity' do
          expect(tech.mandatory_consumption_at(1)).to eq(1.3)
        end

        it 'has conditional consumption equal to the 2x capacity' do
          expect(tech.conditional_consumption_at(1)).to be_within(1e-9).of(0.4)
        end
      end # with capacity of 0.2

      context 'with capacity of 3.0' do
        let(:capacity) { 3.0 }

        it 'has mandatory consumption of 0' do
          expect(tech.mandatory_consumption_at(1)).to be_zero
        end

        it 'has conditional consumption equal to the storage amount' do
          expect(tech.conditional_consumption_at(1)).to eq(2.0)
        end
      end # with capacity of 3.0
    end # with 1.5 storage carried from frame 0
  end # in frame 1

  context 'with no storage amount set' do
    let(:tech) { network_technology(build(:installed_battery, storage: nil)) }

    pending 'should raise an error' do
      expect { tech }.to raise_error
    end
  end # with no storage amount set

  context 'when disabled' do
    let(:tech) do
      network_technology(
        build(:installed_battery, storage: nil), 2, storage: false)
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

    it 'has no load' do
      expect(tech.load_at(0)).to be_zero
    end
  end # when disabled
end
