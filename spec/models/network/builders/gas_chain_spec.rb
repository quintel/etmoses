require 'rails_helper'

module Network
  RSpec.describe Builders::GasChain do
    let(:source) { Graph.new(:gas) }
    let(:chain)  { Builders::GasChain.build(source) }

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
  end # describe Builders::GasChain
end # Network
