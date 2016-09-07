require 'rails_helper'

RSpec.describe Network::Path do
  let(:source) { Network::Node.new(:source) }
  let(:parent) { Network::Node.new(:parent) }
  let(:child)  { Network::Node.new(:child) }

  before do
    source.connect_to(parent)
    parent.connect_to(child)
  end

  let(:path) { Network::Path.find(child) }

  describe '.find' do
    it 'contains the given node' do
      expect(path.to_a.first).to eq(child)
    end

    it 'contains the nodes to the root' do
      expect(path.to_a[1..-1]).to eq([parent, source])
    end
  end

  describe 'available_capacity_at' do
    before do
      allow(child).to receive(:load_at).and_return(1.0)
      allow(parent).to receive(:load_at).and_return(2.0)
      allow(source).to receive(:load_at).and_return(3.0)
    end

    context 'when no node has a capacity' do
      it 'is infinite' do
        expect(path.available_capacity_at(0)).to eq(Float::INFINITY)
      end
    end

    context 'when a node has an exceedance' do
      before { parent.set(:capacity, 1.9) }

      it 'is zero' do
        expect(path.available_capacity_at(0)).to eq(0.0)
      end
    end

    context 'when a capacity restricted node has 0.5 available capacity' do
      before do
        source.set(:capacity, 3.5)
        parent.set(:capacity, 2.6)
      end

      it 'returns 0.3' do
        expect(path.available_capacity_at(0)).to eq(0.5)
      end
    end
  end

  describe 'congested_at?' do
    before do
      allow(child).to receive(:load_at).and_return(1.0)
      allow(parent).to receive(:load_at).and_return(2.0)
      allow(source).to receive(:load_at).and_return(3.0)
    end

    context 'when a node has an exceedance' do
      before { parent.set(:capacity, 1.9) }

      it 'is true' do
        expect(path.congested_at?(0)).to be
      end
    end

    context 'when a node has an excess of production' do
      before do
        allow(parent).to receive(:load_at).and_return(-2.0)
        parent.set(:capacity, 2.1)
      end

      it 'is false' do
        expect(path.congested_at?(0)).to_not be
      end
    end

    context 'when a capacity restricted node has 0.5 available capacity' do
      before do
        source.set(:capacity, 3.5)
        parent.set(:capacity, 2.6)
      end

      it 'is false' do
        expect(path.congested_at?(0)).to_not be
      end
    end
  end
end
