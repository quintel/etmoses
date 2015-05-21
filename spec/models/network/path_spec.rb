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

  describe 'conditional_consumption_at' do
    it 'calls the same on the leaf node' do
      expect(child).to receive(:conditional_consumption_at)
        .with(2).once.and_return(0)

      path.conditional_consumption_at(2)
    end
  end

  describe 'mandatory_consumption_at' do
    it 'calls the same on the leaf node' do
      expect(child).to receive(:mandatory_consumption_at)
        .with(2).once.and_return(0)

      path.mandatory_consumption_at(2)
    end
  end

  describe 'consume' do
    context 'with mandatory load' do
      before do
        child.set(:techs, [
          network_technology(build(:installed_tv, capacity: 10.0))
        ])
      end

      context 'when each node has no existing consumption' do
        it 'assigns consumption to the source node' do
          expect { path.consume(0, 10) }.to change {
            source.consumption_at(0)
          }.from(0).to(10)
        end

        it 'assigns consumption to the intermediate nodes' do
          expect { path.consume(0, 10) }.to change {
            parent.consumption_at(0)
          }.from(0).to(10)
        end

        it 'assigns consumption to the leaf node' do
          expect { path.consume(0, 10) }.to change {
            child.consumption_at(0)
          }.from(0).to(10)
        end
      end # when each node has no existing consumption

      context 'when a node has existing consumption' do
        before { source.consume(0, 10) }

        it 'adds to the load' do
          expect { path.consume(0, 10) }.to change {
            source.consumption_at(0)
          }.from(10).to(20)
        end

        it 'does not add to the child nodes' do
          expect { path.consume(0, 10) }.to change {
            child.consumption_at(0)
          }.from(0).to(10)
        end
      end # when a node has existing consumption

      context 'assigning zero load' do
        it 'adds to the load' do
          expect { path.consume(0, 0) }.to_not change {
            source.consumption_at(0)
          }.from(0)
        end
      end # assigning zero load
    end # with mandatory load

    context 'with conditional load' do
      before do
        child.set(:techs, [
          network_technology(build(:installed_battery, volume: 10.0))
        ])
      end

      it 'assigns conditional consumption to storage technologies' do
        path.consume(0, 10)
        expect(child.get(:techs).first.stored[0]).to eq(10.0)
      end
    end # with conditional load
  end # consume
end
