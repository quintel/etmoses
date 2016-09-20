require 'rails_helper'

RSpec.describe Network::Technologies::Composite::Consumer do
  let(:profile) do
    Network::Curve.from([1.0, 2.0, 1.0, 1.0])
  end

  let(:consumer) do
    described_class.new(FactoryGirl.build(:installed_tv), profile)
  end

  context 'with profile demand of 1.0, equal to capacity' do
    it 'has mandatory consumption of 1.0' do
      expect(consumer.mandatory_consumption_at(0)).to eq(1.0)
    end

    it 'has no conditional consumption' do
      expect(consumer.conditional_consumption_at(0)).to be_zero
    end

    context 'after giving 0.5' do
      before { consumer.receive_mandatory(0, 0.5) }

      it 'has mandatory consumption of 1.0' do
        expect(consumer.mandatory_consumption_at(0)).to eq(1.0)
      end

      it 'has no conditional consumption' do
        expect(consumer.conditional_consumption_at(0)).to be_zero
      end
    end
  end

  context 'with profile demand of 2.0, double capacity' do
    it 'has mandatory consumption of 1.0' do
      expect(consumer.mandatory_consumption_at(0)).to eq(1.0)
    end

    it 'has no conditional consumption' do
      expect(consumer.conditional_consumption_at(0)).to be_zero
    end

    context 'after giving 0.5' do
      before { consumer.receive_mandatory(0, 0.5) }

      it 'has mandatory consumption of 1.0' do
        expect(consumer.mandatory_consumption_at(0)).to eq(1.0)
      end

      it 'has no conditional consumption' do
        expect(consumer.conditional_consumption_at(0)).to be_zero
      end
    end
  end
end
