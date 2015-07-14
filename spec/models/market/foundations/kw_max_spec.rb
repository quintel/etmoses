require 'rails_helper'

module Market::Foundations
  RSpec.describe KwMax do
    let(:node) { Network::Node.new(:thing) }

    context 'with partitions=12' do
      let(:foundation) { KwMax.new(12) }

      context 'and 4380 loads' do
        before { node.set(:load, (0...4380).to_a) }

        it 'returns an array of 12 values' do
          expect(foundation.call(node).length).to eq(12)
        end

        it 'returns the maximum value from each period' do
          expect(foundation.call(node)).to eq([
            364, 729, 1094, 1459, 1824, 2189,
            2554, 2919, 3284, 3649, 4014, 4379
          ])
        end
      end # and 4380 loads

      context 'and 8760 loads' do
        before { node.set(:load, (0...8760).to_a) }

        it 'returns an array of 12 values' do
          expect(foundation.call(node).length).to eq(12)
        end

        it 'returns the maximum value from each period' do
          expect(foundation.call(node)).to eq([
            729, 1459, 2189, 2919, 3649, 4379,
            5109, 5839, 6569, 7299, 8029, 8759
          ])
        end
      end # and 8760 loads
    end # with partitions=12

    context 'with partitions=24' do
      let(:foundation) { KwMax.new(24) }
      before { node.set(:load, (0...8760).to_a) }

      context 'and 8760 loads' do
        it 'returns an array of 24 values' do
          expect(foundation.call(node).length).to eq(24)
        end

        it 'returns the maximum value from each period' do
          expect(foundation.call(node)).to eq([
            364, 729, 1094, 1459, 1824, 2189,
            2554, 2919, 3284, 3649, 4014, 4379,
            4744, 5109, 5474, 5839, 6204, 6569,
            6934, 7299, 7664, 8029, 8394, 8759
          ])
        end
      end # and 8760 loads
    end # with partitions=24
  end # KwMax
end # Market::Foundations
