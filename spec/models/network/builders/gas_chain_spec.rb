require 'rails_helper'

module Network
  RSpec.describe Builders::GasChain do
    let(:source) { Graph.new(:gas) }
    let(:chain)  { Builders::GasChain.build(source, assets) }
    let(:assets) { [] }

    context 'with nil' do
      let(:chain) { Builders::GasChain.build }

      it 'creates a 40-bar level' do
        expect(chain.forty).to be_a(Chain::Layer)
      end

      it 'creates an 8-bar level' do
        expect(chain.eight).to be_a(Chain::Layer)
      end

      it 'creates a 4-bar level' do
        expect(chain.four).to be_a(Chain::Layer)
      end

      it 'creates a "local" 0.125-bar level' do
        expect(chain.local).to be_a(Chain::Layer)
      end

      it 'adds no load source' do
        expect(chain.local.children).to be_empty
      end

      it 'can calculate successfully' do
        expect(chain.forty.call(0)).to be_zero
      end
    end # with nil

    context 'with an empty Gas network' do
      it 'creates 40-bar level' do
        expect(chain.forty).to be_a(Chain::Layer)
      end

      context 'the forty->eight connection' do
        it 'exists' do
          expect(chain.forty.children.length).to eq(1)
        end

        it 'is a Connection' do
          expect(chain.forty.children.first).to be_a(Chain::Connection)
        end

        it 'is connected to the 8-bar network' do
          expect(chain.forty.children.first.children.first)
            .to eq(chain.eight)
        end
      end

      it 'creates an 8-bar level' do
        expect(chain.eight).to be_a(Chain::Layer)
      end

      context 'the eight->four connection' do
        it 'exists' do
          expect(chain.eight.children.length).to eq(1)
        end

        it 'is a Connection' do
          expect(chain.eight.children.first).to be_a(Chain::Connection)
        end

        it 'is connected to the 4-bar network' do
          expect(chain.eight.children.first.children.first)
            .to eq(chain.four)
        end
      end

      it 'creates a 4-bar level' do
        expect(chain.four).to be_a(Chain::Layer)
      end

      context 'the four->local connection' do
        it 'exists' do
          expect(chain.four.children.length).to eq(1)
        end

        it 'is a Connection' do
          expect(chain.four.children.first).to be_a(Chain::Connection)
        end

        it 'is connected to the 0.125-bar network' do
          expect(chain.four.children.first.children.first)
            .to eq(chain.local)
        end
      end

      it 'creates a local 0.125-bar level' do
        expect(chain.four).to be_a(Chain::Layer)
      end

      it 'adds no load source' do
        expect(chain.local.children).to be_empty
      end

      it 'can calculate successfully' do
        expect(chain.forty.call(0)).to be_zero
      end
    end # with an empty gas network

    context 'with a gas network containing a head node; load of 4.0, 6.0' do
      let(:source) do
        graph = Graph.new(:gas)
        graph.add(Node.new(:head, load: [4.0, 6.0]))
        graph
      end

      context 'the local->source connection' do
        it 'exists' do
          expect(chain.local.children.length).to eq(1)
        end

        it 'is Callable' do
          expect(chain.local.children.first).to respond_to(:call)
        end
      end

      it 'computes load of 4.0 in frame 0' do
        expect(chain.forty.call(0)).to eql(4.0)
      end

      it 'computes load of 6.0 in frame 1' do
        expect(chain.forty.call(1)).to eql(6.0)
      end
    end # with a gas connection containing a head node; load of 4.0, 6.0

    context 'with some assets and loads of 2, 8, 35' do
      let(:source) do
        graph = Graph.new(:gas)
        graph.add(Node.new(:head, load: [2.0, 8.0, 35.0]))
        graph
      end

      let(:assets) do
        [
          InstalledGasAsset.new(
            pressure_level_index: 1, # eight->four
            part: 'connectors',
            type: 'inefficient_connector',
            amount: 10
          ),
          InstalledGasAsset.new(
            pressure_level_index: 2, # forty->eight
            part: 'connectors',
            type: 'inefficient_connector',
            amount: 5
          ),
          InstalledGasAsset.new(
            pressure_level_index: 1, # forty->eight
            part: 'compressors',
            type: 'compressor_8_bar',
            amount: 5
          )
        ]
      end

      context 'the asset on :forty->:eight' do
        let(:connection) { chain.forty.children.first }

        it 'sets the upward efficiency' do
          expect(connection.upward.efficiency).to eq(1.0)
        end

        it 'sets the downward efficiency' do
          expect(connection.downward.efficiency).to eq(0.5)
        end

        it 'sets the upward capacity' do
          expect(connection.upward.capacity).to eq(Float::INFINITY)
        end

        it 'sets the downward capacity' do
          expect(connection.downward.capacity).to eq(10.0)
        end
      end

      context 'the asset on :eight->:four' do
        let(:connection) { chain.eight.children.first }

        it 'sets the upward efficiency' do
          expect(connection.upward.efficiency).to eq(0.8)
        end

        it 'sets the downward efficiency' do
          expect(connection.downward.efficiency).to eq(0.5)
        end

        it 'sets the upward capacity' do
          expect(connection.upward.capacity).to eq(15.0)
        end

        it 'sets the downward capacity' do
          expect(connection.downward.capacity).to eq(20.0)
        end
      end

      context 'in frame 0' do
        it 'computes load of 8.0 on the 40-bar network' do
          expect(chain.forty.call(0)).to eql(2.0 / 0.5 / 0.5)
        end

        it 'computes load of 4.0 on the 8-bar network' do
          expect(chain.eight.call(0)).to eql(2.0 / 0.5)
        end

        it 'computes load of 2.0 on the 4-bar network' do
          expect(chain.four.call(0)).to eql(2.0)
        end

        it 'computes load of 2.0 on the local network' do
          expect(chain.local.call(0)).to eql(2.0)
        end
      end

      context 'in frame 1' do
        it 'computes load of 20.0 on the 40-bar network' do
          # capacity / efficiency (10 / 0.5 = 20) is limiting
          expect(chain.forty.call(1)).to eql(20.0)
        end

        it 'computes load of 16.0 on the 8-bar network' do
          expect(chain.eight.call(1)).to eql(8.0 / 0.5)
        end

        it 'computes load of 8.0 on the 4-bar network' do
          expect(chain.four.call(1)).to eql(8.0)
        end

        it 'computes load of 8.0 on the local network' do
          expect(chain.local.call(1)).to eql(8.0)
        end
      end

      context 'in frame 2' do
        it 'computes load of 20.0 on the 40-bar network' do
          # capacity / efficiency (10 / 0.5 = 20) is limiting
          expect(chain.forty.call(2)).to eql(20.0)
        end

        it 'computes load of 12.0 on the 8-bar network' do
          # capacity / efficiency (20 / 0.5 = 40) is limiting
          expect(chain.eight.call(2)).to eql(40.0)
        end

        it 'computes load of 4.0 on the 4-bar network' do
          expect(chain.four.call(2)).to eql(35.0)
        end

        it 'computes load of 6.0 on the local network' do
          expect(chain.local.call(2)).to eql(35.0)
        end
      end # in frame 2
    end # with some assets and loads of 2, 8, 35
  end # describe Builders::GasChain
end # Network
