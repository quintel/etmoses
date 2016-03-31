require 'rails_helper'

module Network::Chain
  RSpec.describe Slot do
    context 'with no arguments' do
      let(:slot) { Slot.upward }

      it 'does not affect flow' do
        expect(slot.call(50)).to eql(50.0)
      end
    end # with no arguments

    context 'with an efficiency of 0.8' do
      let(:slot) { Slot.upward(efficiency: 0.8) }

      it 'reduces flow of 10.0 to 8.0' do
        expect(slot.call(10.0)).to eql(8.0)
      end

      it 'reduces flow of 9 to 7.2' do
        expect(slot.call(9)).to eql(7.2)
      end
    end # with an efficiency of 0.8

    context 'a downward slot, with an efficiency of 0.8' do
      let(:slot) { Slot.downward(efficiency: 0.8) }

      it 'increases flow of 10.0 to 12.5' do
        expect(slot.call(10.0)).to eql(12.5)
      end

      it 'increases flow of 9 to 11.25' do
        expect(slot.call(9)).to eql(11.25)
      end
    end # a downward slot, with an efficiency of 0.8

    context 'with an efficiency of nil' do
      let(:slot) { Slot.upward(efficiency: nil) }

      it 'does not affect flow (defaults to 1.0)' do
        expect(slot.call(50)).to eql(50.0)
      end
    end # with an efficiency of nil

    context 'with an efficiency of 1.1' do
      let(:slot) { Slot.upward(efficiency: 1.1) }

      it 'raises an error' do
        expect { slot }.to raise_error
      end
    end # with an efficiency of 1.1

    context 'with no capacity given' do
      let(:slot) { Slot.upward }

      it 'does not affect flow' do
        expect(slot.call(50)).to eql(50.0)
      end
    end # with no capacity given

    context 'with a capacity of nil' do
      let(:slot) { Slot.upward(capacity: nil) }

      it 'does not affect flow (defaults to Infinity)' do
        expect(slot.call(50.0)).to eql(50.0)
      end
    end # with a capacity of nil

    context 'with a capacity of -1.0' do
      let(:slot) { Slot.upward(capacity: -1.0) }

      it 'it raises an error' do
        expect { slot }.to raise_error
      end
    end # with a capacity of -1

    context 'with a capacity of 2.0' do
      let(:slot) { Slot.upward(capacity: 2.0) }

      it 'permits 1.9 to flow unchanged' do
        expect(slot.call(1.9)).to eql(1.9)
      end

      it 'permits 2.0 to flow unchanged' do
        expect(slot.call(2.0)).to eql(2.0)
      end

      it 'reduces flow of 2.1 to 2.0' do
        expect(slot.call(2.1)).to eql(2.0)
      end
    end # with a capacity of 2.0

    context 'with a capacity of 1' do
      let(:slot) { Slot.upward(capacity: 1) }

      # Asserts than an Integer capacity returns Floats
      it 'reduces flow of 2.0 to 1.0' do
        expect(slot.call(2.0)).to eql(1.0)
      end

      it 'reduces flow of 2 to 1.0' do
        expect(slot.call(2)).to eql(1.0)
      end
    end # with a capacity of 1
  end # Slot
end
