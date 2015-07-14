require 'rails_helper'

module Market::Foundations
  RSpec.describe KwhProduced do
    let(:node) { Network::Node.new(:node, resolution: 1) }

    context 'given a node with loads [-1, -2, -1, -3]' do
      before  { node.set(:load, [-1.0, -2.0, -1.0, -3.0]) }

      context 'and a resolution of 1' do
        it 'produces 7 kWh' do
          expect(KwhProduced.call(node)).to eq(7)
        end
      end # and a resolution of 1

      context 'and a resolution of 0.25' do
        before { node.set(:resolution, 0.25) }

        it 'produces 1.75 kWh' do
          expect(KwhProduced.call(node)).to eq(1.75)
        end
      end # and a resolution of 4
    end # given a node which only produces

    context 'given a node with loads [1, 2, 1, 3]' do
      before  { node.set(:load, [1.0, 2.0, 1.0, 3.0]) }

      it 'produces nothing' do
        expect(KwhProduced.call(node)).to be_zero
      end
    end # given a node which only consumes

    context 'given a node with loads [-2, 2, -4, 2]' do
      before  { node.set(:load, [-2.0, 2.0, -4.0, 2.0]) }

      context 'and a resolution of 1' do
        it 'produces 6 kWh' do
          expect(KwhProduced.call(node)).to eq(6)
        end
      end # and a resolution of 1

      context 'and a resolution of 0.25' do
        before { node.set(:resolution, 0.25) }

        it 'produces 1.5 kWh' do
          expect(KwhProduced.call(node)).to eq(1.5)
        end
      end # and a resolution of 4
    end # given a node which produces and consumes
  end
end
