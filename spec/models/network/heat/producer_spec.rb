require 'rails_helper'

module Network::Heat
  RSpec.describe Producer do
    let(:profile)  { Network::Curve.new([2.0, 2.0]) }
    let(:producer) { Producer.new(nil, profile, {}) }

    context 'with production of 2.0' do
      it 'has 2.0 available production' do
        expect(producer.available_production_at(0)).to eq(2.0)
      end

      it 'has no mandatory consumption' do
        expect(producer.mandatory_consumption_at(0)).to be_zero
      end

      it 'has no conditional consumption' do
        expect(producer.conditional_consumption_at(0, nil)).to be_zero
      end

      context 'taking 1.0' do
        it 'returns 1.0' do
          expect(producer.take(0, 1.0)).to eq(1.0)
        end

        it 'leaves 1.0 energy remaining' do
          producer.take(0, 1.0)
          expect(producer.available_production_at(0)).to eq(1.0)
        end

        it 'does not affect the next frame' do
          expect { producer.take(0, 1.0) }
            .to_not change { producer.available_production_at(1) }
        end
      end # taking 1.0

      context 'taking 2.0' do
        it 'returns 2.0' do
          expect(producer.take(0, 2.0)).to eq(2.0)
        end

        it 'leaves no energy remaining' do
          producer.take(0, 2.0)
          expect(producer.available_production_at(0)).to be_zero
        end
      end # taking 2.0

      context 'taking 2.5' do
        it 'returns 2.0' do
          expect(producer.take(0, 2.5)).to eq(2.0)
        end

        it 'leaves no energy remaining' do
          producer.take(0, 2.5)
          expect(producer.available_production_at(0)).to be_zero
        end
      end # taking 2.5
    end # with production of 2.0
  end # Producer
end # Network::Heat
