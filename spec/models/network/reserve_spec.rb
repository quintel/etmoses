require 'rails_helper'

RSpec.describe Network::Reserve do
  let(:reserve) { Network::Reserve.new }

  it 'starts empty' do
    expect(reserve.stored_at(0)).to be_zero
  end

  describe '#to_s' do
    it 'includes the volume' do
      expect(reserve.to_s).to include('Infinity')
    end
  end

  describe '#inspect' do
    it 'includes the volume' do
      expect(reserve.inspect).to include('Infinity')
    end
  end

  context 'adding 5 in frame 0' do
    before { reserve.add(0, 5.0) }

    it 'adds 5 in frame 0' do
      expect(reserve.stored_at(0)).to eq(5.0)
    end

    it 'carries 5 over to the start of frame 1' do
      expect(reserve.stored_at(1)).to eq(5.0)
    end

    context 'adding 2.5 in frame 1' do
      before { reserve.add(0, 2.5) }

      it 'has 7.5 stored in frame 1' do
        expect(reserve.stored_at(1)).to eq(7.5)
      end

      it 'carries 7.5 over to the start of frame 2' do
        expect(reserve.stored_at(2)).to eq(7.5)
      end
    end

    context 'taking 1.2 in frame 1' do
      let!(:taken) { reserve.take(0, 1.2) }

      it 'returns that 1.2 was taken' do
        expect(taken).to eq(1.2)
      end

      it 'has 3.8 stored in frame 1' do
        expect(reserve.stored_at(1)).to eq(3.8)
      end

      it 'carries 3.8 over to frame 2' do
        expect(reserve.stored_at(2)).to eq(3.8)
      end
    end

    context 'taking 5.2 in frame 1' do
      let!(:taken) { reserve.take(0, 5.2) }

      it 'returns that 5.0 was taken' do
        expect(taken).to eq(5.0)
      end

      it 'has nothing stored in frame 1' do
        expect(reserve.stored_at(1)).to be_zero
      end

      it 'carries nothing over to frame 2' do
        expect(reserve.stored_at(2)).to be_zero
      end
    end
  end # adding 5 in frame 0

  context 'with a volume of 2.0' do
    let(:reserve) { Network::Reserve.new(2.0) }

    context 'adding 1.0' do
      let!(:added) { reserve.add(0, 1.0) }

      it 'returns 1.0' do
        expect(added).to eq(1.0)
      end

      it 'adds 1.0 to frame 0' do
        expect(reserve.stored_at(0)).to eq(1.0)
      end

      it 'has 1.0 unfilled' do
        expect(reserve.unfilled_at(0)).to eq(1.0)
      end
    end

    context 'adding 2.0' do
      let!(:added) { reserve.add(0, 2.0) }

      it 'returns 2.0' do
        expect(added).to eq(2.0)
      end

      it 'adds 2.0 to frame 0' do
        expect(reserve.stored_at(0)).to eq(2.0)
      end

      it 'is full' do
        expect(reserve.unfilled_at(0)).to be_zero
      end
    end

    context 'adding 2.1' do
      let!(:added) { reserve.add(0, 2.1) }

      it 'returns 2.0' do
        expect(added).to eq(2.0)
      end

      it 'adds 2.0 to frame 0' do
        expect(reserve.stored_at(0)).to eq(2.0)
      end

      it 'is full' do
        expect(reserve.unfilled_at(0)).to be_zero
      end
    end
  end # with a volume of 2.0
end
