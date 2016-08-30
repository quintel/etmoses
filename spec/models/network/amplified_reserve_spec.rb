require 'rails_helper'
require_relative 'shared_reserve_specs'

RSpec.describe Network::AmplifiedReserve do
  let(:reserve) { described_class.new }

  it 'starts empty' do
    expect(reserve.at(0)).to be_zero
  end

  describe '#to_s' do
    it 'includes the low-energy volume' do
      expect(reserve.to_s).to include('{Infinity')
    end

    it 'includes the high-energy volume' do
      expect(reserve.to_s).to include('Infinity}')
    end
  end

  describe '#inspect' do
    it 'includes the low-energy volume' do
      expect(reserve.inspect).to include('low_volume=Infinity')
    end

    it 'includes the high-energy volume' do
      expect(reserve.inspect).to include('high_volume=Infinity')
    end
  end

  include_examples 'a network reserve'

  context 'with low_volume=2 and high_volume=3' do
    let(:reserve) { described_class.new(2.0, 3.0) }

    context 'adding 2.5 low-energy in frame 0' do
      let!(:added) { reserve.add(0, 2.5) }

      it 'returns 2.0' do
        expect(added).to eq(2.0)
      end

      it 'adds 2.0 to the reserve' do
        expect(reserve.at(0)).to eq(2.0)
      end

      it 'carries 2.0 over to the next frame' do
        expect(reserve.at(1)).to eq(2.0)
      end

      it 'has low-energy unfilled volume of 0.0' do
        expect(reserve.unfilled_at(1)).to be_zero
      end

      it 'has high-energy unfilled volume of 1.0' do
        expect(reserve.unfilled_at(1, true)).to eq(1.0)
      end

      it 'has loads of [2.0, 0.0, ...]' do
        5.times(&reserve.method(:at))
        expect(reserve.load.to_a.take(2)).to eq([2.0, 0.0])
      end

      context 'taking 1.5 in frame 1' do
        let!(:taken) { reserve.take(1, 1.5) }

        it 'returns 1.5' do
          expect(taken).to eq(1.5)
        end

        it 'has 0.5 remaining in the reserve' do
          expect(reserve.at(1)).to eq(0.5)
        end

        it 'has loads of [2, -1.5, 0, ...]' do
          5.times(&reserve.method(:at))

          expect(reserve.load.to_a.take(4))
            .to eq([2.0, -1.5, 0.0, 0.0])
        end
      end

      context 'taking 3.0 in frame 1' do
        let!(:taken) { reserve.take(1, 3.0) }

        it 'returns 2.0' do
          expect(taken).to eq(2.0)
        end

        it 'has nothing remaining in the reserve' do
          expect(reserve.at(1)).to be_zero
        end

        it 'has loads of [2, -2, 0, ...]' do
          3.times(&reserve.method(:at))

          expect(reserve.load.to_a.take(3))
            .to eq([2.0, -2.0, 0.0])
        end
      end
    end # adding 2.5 low-energy in frame 0

    context 'adding 2.5 high-energy in frame 0' do
      let!(:added) { reserve.add(0, 2.5, true) }

      it 'returns 2.5' do
        expect(added).to eq(2.5)
      end

      it 'adds 2.5 to the reserve' do
        expect(reserve.at(0)).to eq(2.5)
      end

      it 'carries 2.5 over to the next frame' do
        expect(reserve.at(1)).to eq(2.5)
      end

      it 'has loads of [2.5, 0.0, ...]' do
        3.times(&reserve.method(:at))
        expect(reserve.load.to_a.take(3)).to eq([2.5, 0.0, 0.0])
      end

      context 'taking 1.5 in frame 1' do
        let!(:taken) { reserve.take(1, 1.5) }

        it 'returns 1.5' do
          expect(taken).to eq(1.5)
        end

        it 'has 1.0 stored in the reserve' do
          expect(reserve.at(1)).to eq(1.0)
        end

        it 'has low-energy unfilled volume of 1.0' do
          expect(reserve.unfilled_at(1)).to eq(1.0)
        end

        it 'has high-energy unfilled volume of 2.0' do
          expect(reserve.unfilled_at(1, true)).to eq(2.0)
        end

        it 'has loads of [2.5, 1.0, ...]' do
          4.times(&reserve.method(:at))

          expect(reserve.load.to_a.take(4))
            .to eq([2.5, -1.5, 0.0, 0.0])
        end
      end

      context 'taking 3.0 in frame 1' do
        let!(:taken) { reserve.take(1, 3.0) }

        it 'returns 2.5' do
          expect(taken).to eq(2.5)
        end

        it 'has nothing stored in the reserve' do
          expect(reserve.at(1)).to be_zero
        end

        it 'has low-energy unfilled volume of 2.0' do
          expect(reserve.unfilled_at(1)).to eq(2.0)
        end

        it 'has high-energy unfilled volume of 3.0' do
          expect(reserve.unfilled_at(1, true)).to eq(3.0)
        end

        it 'has loads of [2.5, 0.0, ...]' do
          4.times(&reserve.method(:at))

          expect(reserve.load.to_a.take(4))
            .to eq([2.5, -2.5, 0.0, 0.0])
        end
      end
    end # adding 2.5 high-energy in frame 0
  end # with low_volume=2 and high_volume=3

  context 'with low_volume=2 and high_volume=3 and 1.0 decay' do
    let(:reserve) { described_class.new(2.0, 2.5) { |*| 1.0 } }

    context 'with 2.5 carried over from frame 0' do
      before { reserve.add(0, 2.5, true) }

      it 'has 1.5 stored in frame 1' do
        expect(reserve.at(1)).to eq(1.5)
      end

      it 'has 0.5 stored in frame 2' do
        expect(reserve.at(2)).to eq(0.5)
      end

      it 'has nothing stored in frame 3' do
        expect(reserve.at(3)).to be_zero
      end

      it 'has loads of [2.5, -1, -1, -0.5, 0.0, ...]' do
        5.times(&reserve.method(:at))

        expect(reserve.load.to_a.take(5))
          .to eq([2.5, -1.0, -1.0, -0.5, 0.0])
      end
    end
  end # with low_volume=2 and high_volume=3 and 1.0 decay
end
