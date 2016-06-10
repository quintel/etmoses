require 'rails_helper'

module Network::Heat
  RSpec.describe Consumer do
    let(:profile)   { Network::Curve.new([2.0, 4.0]) }
    let(:installed) { build(:installed_space_heater_heat_exchanger) }
    let(:consumer)  { Consumer.new(installed, profile, {}) }

    it 'is a consumer' do
      expect(consumer).to be_consumer
    end

    it 'is not a producer' do
      expect(consumer).to_not be_producer
    end

    it 'is excess constrained' do
      expect(consumer).to be_excess_constrained
    end

    it 'is not capacity constrained' do
      expect(consumer).to_not be_capacity_constrained
    end

    context 'with a profile containing 2.0, 4.0' do
      context 'in frame 0' do
        it 'has no production' do
          expect(consumer.production_at(0)).to be_zero
        end

        it 'has mandatory consumption of 2.0' do
          expect(consumer.mandatory_consumption_at(0)).to eq(2.0)
        end

        it 'has no conditional consumption' do
          expect(consumer.conditional_consumption_at(0)).to be_zero
        end
      end # in frame 0

      context 'in frame 1' do
        it 'has no production' do
          expect(consumer.production_at(1)).to be_zero
        end

        it 'has mandatory consumption of 4.0' do
          expect(consumer.mandatory_consumption_at(1)).to eq(4.0)
        end

        it 'has no conditional consumption' do
          expect(consumer.conditional_consumption_at(1)).to be_zero
        end
      end # in frame 1

      context 'and a tech capacity of 3.0' do
        let(:installed) do
          build(:installed_space_heater_heat_exchanger, capacity: 3.0)
        end

        context 'in frame 0' do
          it 'has mandatory consumption of 2.0' do
            expect(consumer.mandatory_consumption_at(0)).to eq(2.0)
          end
        end # in frame 0

        context 'in frame 1' do
          it 'has mandatory consumption of 3.0' do
            expect(consumer.mandatory_consumption_at(1)).to eq(3.0)
          end
        end # in frame 1
      end # and a tech capacity of 3.0
    end # with a profile containing 2.0, 4.0
  end # Consumer
end # Network::Heat
