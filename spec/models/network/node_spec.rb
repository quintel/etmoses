require 'rails_helper'

RSpec.describe Network::Node do
  include Moses::Spec::Network

  let(:node) { Network::Node.new(:a) }

  describe 'production_at' do
    context 'when the node has no children, nor technologies' do
      it 'returns 0.0' do
        expect(node.production_at(0)).to be_zero
      end
    end

    context 'when the node has technologies but no children' do
      before do
        node.set(:techs, [
          network_technology(build(:installed_pv, capacity: -2.0)),
          network_technology(build(:installed_pv, capacity: -1.5))
        ])
      end

      it 'includes load from its production technologies' do
        expect(node.production_at(0)).to eq(3.5)
      end

      it 'omits load from consumption technologies' do
        node.get(:techs).push(
          network_technology(build(:installed_tv, capacity: 2.0)))

        expect(node.production_at(0)).to eq(3.5)
      end
    end # when the node has technologies but no children

    context 'when the node has children but no technologies' do
      let(:child_one) { Network::Node.new(:c1) }
      let(:child_two) { Network::Node.new(:c2) }

      before do
        child_one.set(:techs, [
          network_technology(build(:installed_pv, capacity: -3.0))
        ])

        child_two.set(:techs, [
          network_technology(build(:installed_pv, capacity: -2.5))
        ])

        node.connect_to(child_one)
        node.connect_to(child_two)
      end

      it 'sums the load of its children' do
        expect(node.production_at(0)).to eq(5.5)
      end
    end # when the node has children but no technologies

    context 'when the node has both technologies and children' do
      let(:child) { Network::Node.new(:c1) }

      before do
        node.set(:techs, [
          network_technology(build(:installed_pv, capacity: -4.0))
        ])

        child.set(:techs, [
          network_technology(build(:installed_pv, capacity: -3.5))
        ])

        node.connect_to(child)
      end

      it 'sums its technology load and that of its children' do
        expect(node.production_at(0)).to eq(7.5)
      end
    end # when the node has both technologies and children
  end # production_at

  context 'available_capacity_at' do
    before { allow(node).to receive(:load_at).and_return(2.0) }

    context 'when no capacity is set' do
      it 'has unlimited available capacity' do
        expect(node.available_capacity_at(0)).to eq(Float::INFINITY)
      end

      context 'when no load is set' do
        before { allow(node).to receive(:load_at).and_return(0.0) }

        it 'has unlimited available capacity' do
          expect(node.available_capacity_at(0)).to eq(Float::INFINITY)
        end
      end
    end

    context 'when no load is set' do
      before do
        allow(node).to receive(:load_at).and_return(0.0)
        node.set(:capacity, 3.0)
      end

      it 'returns the capacity' do
        expect(node.available_capacity_at(0)).to eq(3.0)
      end
    end

    context 'when capacity is greater than the load' do
      before { node.set(:capacity, 3.0) }

      it 'has available capacity' do
        expect(node.available_capacity_at(0)).to eq(1.0)
      end
    end

    context 'when the capacity is less than the load' do
      before { node.set(:capacity, 1.0) }

      it 'has no available capacity' do
        expect(node.available_capacity_at(0)).to be_zero
      end
    end
  end # available_capacity_at

  context '#congested_at? with a load of 7.5' do
    before { allow(node).to receive(:load_at).and_return(7.5) }

    context 'and no capacity on the node' do
      before { node.set(:capacity, nil) }

      it 'returns false' do
        expect(node).to_not be_congested_at(0)
      end
    end

    context 'and a capacity of 5.0' do
      before { node.set(:capacity, 5.0) }

      it 'returns true' do
        expect(node).to be_congested_at(0)
      end
    end

    context 'and a capacity of 7.5' do
      before { node.set(:capacity, 7.5) }

      it 'returns false' do
        expect(node).to_not be_congested_at(0)
      end
    end

    context 'and a capacity of 10.0' do
      before { node.set(:capacity, 10.0) }

      it 'returns false' do
        expect(node).to_not be_congested_at(0)
      end
    end
  end # congested_at?

  describe 'energy_at, with a load of 2.0' do
    before do
      allow(node).to receive(:load_at).and_return(2.0)
      node.cache_load_at!(0)
    end

    context 'with a resolution of 1.0' do
      before { node.set(:resolution, 1.0) }

      it 'has energy of 2.0' do
        expect(node.energy_at(0)).to eq(2.0)
      end
    end # with a resolution of 1.0

    context 'with a resolution of 0.25' do
      before { node.set(:resolution, 0.25) }

      it 'has energy of 0.5' do
        expect(node.energy_at(0)).to eq(0.5)
      end
    end # with a resolution of 0.25
  end # energy_at
end
