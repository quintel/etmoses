require 'rails_helper'

RSpec.describe NetworkCache::LoadSetter do
  context 'with three nodes: [a], [b], and [c]' do
    let(:network) do
      network = Network::Graph.new(:electricity)

      network.add(Network::Node.new(:a))
      network.add(Network::Node.new(:b))
      network.add(Network::Node.new(:c))

      network
    end

    context 'setting loads on [a] and [c]' do
      let(:keys) { %i( a c ) }

      before do
        NetworkCache::LoadSetter.set(network, keys) do |node|
          [node.key, 1]
        end
      end

      it 'yields [a] and [c]' do
        yielded = []

        NetworkCache::LoadSetter.set(network, keys) do |node|
          yielded.push(node)
          []
        end

        expect(yielded).to eq([network.node(:a), network.node(:c)])
      end

      it 'sets a load on [a]' do
        expect(network.node(:a).load).to eq([:a, 1])
      end

      it 'sets a load on [c]' do
        expect(network.node(:c).load).to eq([:c, 1])
      end

      it 'sets no load on [b]' do
        expect(network.node(:b).load).to be_empty
      end
    end # setting loads on [a] and [c]

    context 'providing no node keys' do
      before do
        NetworkCache::LoadSetter.set(network) do |node|
          [node.key, 1]
        end
      end

      it 'yields [a], [b], and [c]' do
        yielded = []

        NetworkCache::LoadSetter.set(network) do |node|
          yielded.push(node)
          []
        end

        expect(yielded).to eq([
          network.node(:a),
          network.node(:b),
          network.node(:c)
        ])
      end

      it 'sets a load on [a]' do
        expect(network.node(:a).load).to eq([:a, 1])
      end

      it 'sets a load on [b]' do
        expect(network.node(:b).load).to eq([:b, 1])
      end

      it 'sets a load on [c]' do
        expect(network.node(:c).load).to eq([:c, 1])
      end
    end # providing no node keys

    context 'providing node keys [a] and [z]' do
      let(:keys) { %i( a z ) }

      before do
        NetworkCache::LoadSetter.set(network, keys) do |node|
          [node.key, 1]
        end
      end

      it 'yields [a]' do
        yielded = []

        NetworkCache::LoadSetter.set(network, keys) do |node|
          yielded.push(node)
          []
        end

        expect(yielded).to eq([network.node(:a)])
      end

      it 'sets a load on [a]' do
        expect(network.node(:a).load).to eq([:a, 1])
      end

      it 'sets no load on [b]' do
        expect(network.node(:b).load).to be_empty
      end

      it 'sets no load on [c]' do
        expect(network.node(:c).load).to be_empty
      end
    end # providing node keys [a] and [z]
  end # with three nodes: [a], [b], and [c]
end
