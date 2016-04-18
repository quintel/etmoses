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

      context 'with a flow of 10.0' do
        it 'reduces flow to 8.0' do
          expect(slot.call(10.0)).to eql(8.0)
        end

        it 'has 2.0 loss' do
          expect(slot.loss(10.0)).to eq(2.0)
        end

        it 'has no energy constrained' do
          expect(slot.constrained(10.0)).to be_zero
        end
      end

      it 'reduces flow of 9 to 7.2' do
        expect(slot.call(9)).to eql(7.2)
      end
    end # with an efficiency of 0.8

    context 'a downward slot, with an efficiency of 0.8' do
      let(:slot) { Slot.downward(efficiency: 0.8) }

      context 'with a flow of 10.0' do
        it 'increases flow to 12.5' do
          expect(slot.call(10.0)).to eql(12.5)
        end

        it 'has 2.5 loss' do
          expect(slot.loss(10.0)).to eq(2.5)
        end

        it 'has no energy constrained' do
          expect(slot.constrained(10.0)).to be_zero
        end
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

      it 'has no loss' do
        expect(slot.loss(50.0)).to be_zero
      end

      it 'has no energy constrained' do
        expect(slot.constrained(50.0)).to be_zero
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

      context 'with flow of 2.1' do
        it 'reduces flow of 2.1 to 2.0' do
          expect(slot.call(2.1)).to eql(2.0)
        end

        it 'has no loss' do
          expect(slot.loss(2.1)).to be_zero
        end

        it 'has 0.1 energy constrained' do
          expect(slot.constrained(2.1)).to eq(2.1 - 2.0)
        end
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

    context 'with a capacity of 0.0' do
      let(:slot) { Slot.upward(capacity: 0.0) }

      it 'raises an error' do
        expect { slot }.to raise_error
      end
    end

    context 'with an upward efficiency of 0.8 and capacity of 5.0' do
      let(:slot) { Slot.upward(efficiency: 0.8, capacity: 5.0) }

      context 'with a flow of 10.0' do
        it 'decreases flow to 5.0' do
          expect(slot.call(10.0)).to eql(5.0)
        end

        it 'has 2.0 loss' do
          # 10 * 0.8 = 8.0 flows on, 2.0 loss.
          expect(slot.loss(10.0)).to eq(2.0)
        end

        it 'has 3.0 energy constrained' do
          # 8.0 after loss, 5.0 constraint: 5.0 flows, 3.0 constrained.
          expect(slot.constrained(10.0)).to eq((10.0 * 0.8) - 5.0)
        end
      end
    end # with an upward efficiency of 0.8 and capacity of 5.0

    context 'with a downward efficiency of 0.8 and capacity of 5.0' do
      let(:slot) { Slot.downward(efficiency: 0.8, capacity: 5.0) }

      # Output constraint means at most 5.0 of the output can come from the
      # parent component.
      #
      # Therefore:
      #
      #   * There is a 5.0 deficit ("constrained")
      #
      #   * The demand on the parent is 6.25; (the output is 80% efficient)
      #     therefore the parent must output 6.25 to supply 5.0 at the other
      #     end of the connection.

      context 'with a flow of 10.0' do
        it 'decreases flow to 6.25' do
          expect(slot.call(10.0)).to eql(6.25)
        end

        it 'has 1.25 loss' do
          expect(slot.loss(10.0)).to eq(1.25)
        end

        it 'has 5.0 energy constrained' do
          expect(slot.constrained(10.0)).to eq(5.0)
        end
      end
    end # with a downward efficiency of 0.8 and capacity of 5.0
  end # Slot
end
