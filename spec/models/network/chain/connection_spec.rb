require 'rails_helper'

module Network::Chain
  RSpec.describe Connection do
    # Slots
    let(:upward)   { Slot.upward }
    let(:downward) { Slot.downward }

    let(:connection) do
      Connection.new(upward: upward, downward: downward)
        .connect_to(->(*) { load })
    end

    context 'with a child load of 0.0' do
      let(:load) { 0.0 }

      context 'with default upward and downward slots' do
        it 'has no load' do
          expect(connection.call(0)).to be_zero
        end
      end

      context 'with an efficiencies of 0.8' do
        let(:upward)   { Slot.upward(efficiency: 0.8) }
        let(:downward) { Slot.downward(efficiency: 0.8) }

        it 'has no load' do
          expect(connection.call(0)).to be_zero
        end
      end

      context 'with a capacities of 1.0' do
        let(:upward)   { Slot.upward(capacity: 1.0) }
        let(:downward) { Slot.downward(capacity: 1.0) }

        it 'has no load' do
          expect(connection.call(0)).to be_zero
        end
      end

      context 'with a efficiencies of 0.8 and capacities of 1.0' do
        let(:upward)   { Slot.upward(efficiency: 0.8, capacity: 1.0) }
        let(:downward) { Slot.downward(efficiency: 0.8, capacity: 1.0) }

        it 'has no load' do
          expect(connection.call(0)).to be_zero
        end
      end
    end # with a child load of 0.0

    context 'with a child load of 2.0' do
      let(:load) { 2.0 }

      context 'with default upward and downward slots' do
        it 'passes load through without change' do
          expect(connection.call(0)).to eql(2.0)
        end
      end

      context 'with an downward efficiency of 0.8' do
        let(:downward) { Slot.downward(efficiency: 0.8) }

        it 'increases load to 2.5' do
          expect(connection.call(0)).to eql(2.5)
        end
      end

      context 'with a downward capacity of 1.0' do
        let(:downward) { Slot.downward(capacity: 1.0) }

        it 'decreases load to 1.0' do
          expect(connection.call(0)).to eql(1.0)
        end
      end

      context 'with a downward efficiency of 0.8 and capacity of 1.0' do
        let(:downward) { Slot.downward(efficiency: 0.8, capacity: 1.0) }

        it 'decreases load to 1.0' do
          expect(connection.call(0)).to eql(1.0)
        end
      end
    end # with a child load of 2.0

    context 'with a child load of -2.0' do
      let(:load) { -2.0 }

      context 'with default upward and downward slots' do
        it 'passes load through without change' do
          expect(connection.call(0)).to eql(-2.0)
        end
      end

      context 'with an upward efficiency of 0.8' do
        let(:upward) { Slot.upward(efficiency: 0.8) }

        it 'decreases load to -1.6' do
          expect(connection.call(0)).to eql(-1.6)
        end
      end

      context 'with a upward capacity of 1.0' do
        let(:upward) { Slot.upward(capacity: 1.0) }

        it 'decreases load to -1.0' do
          expect(connection.call(0)).to eql(-1.0)
        end
      end

      context 'with a upward efficiency of 0.8 and capacity of 1.0' do
        let(:upward) { Slot.upward(efficiency: 0.8, capacity: 1.0) }

        it 'decreases load to -1.0' do
          expect(connection.call(0)).to eql(-1.0)
        end
      end
    end # with a child load of -2.0
  end
end
