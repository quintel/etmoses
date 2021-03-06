require 'rails_helper'

RSpec.describe TestingGround::TechnologyPartitioner do
  let(:partitioner) {
    TestingGround::TechnologyPartitioner.new(technology, size).partition
  }

  describe "non composite" do
    let(:technology) { InstalledTechnology.new(units: 5) }
    let(:size) { 4 }

    it 'partitions a technology' do
      expect(partitioner.size).to eq(4)
    end

    it 'keeps all the original parts' do
      expect(partitioner.sum(&:units)).to eq(5)
    end
  end

  describe "a single composite" do
    let(:technology){
      InstalledTechnology.new(units: 10, composite: true, composite_value: 'buffer_1')
    }

    let(:size) { 3 }

    describe "with one associate" do
      before do
        technology.associates = [
          InstalledTechnology.new(units: 10, buffer: technology.composite_value, type: 'a')
        ]
      end

      it 'partitions composite technologies with only one technology type' do
        expect(partitioner.map(&:units)).to eq([4, 3, 3])
      end

      it "sets the correct units for the associates" do
        expect(partitioner.map{|t| t.associates.map(&:units) }.flatten).to eq([4, 3, 3])
      end
    end

    describe "with two associates" do
      before do
        technology.associates = [
          InstalledTechnology.new(units: 10, buffer: technology.composite_value, type: 'a'),
          InstalledTechnology.new(units: 4, buffer: technology.composite_value, type: 'b')
        ]
      end

      let(:size) { 2 }

      it 'partitions composite technologies with only one technology type' do
        expect(partitioner.map(&:units)).to eq([5, 5])
      end

      it 'sets the correct units for associates' do
        expect(partitioner.map{|t| t.associates.map(&:units) }).to eq([[5,5], [5,5]])
      end
    end

    describe "uneven associates" do
      describe "with two associates in sizes of 3, 5 units" do
        before do
          technology.associates = [
            InstalledTechnology.new(units: 5, buffer: technology.composite_value, type: "a"),
            InstalledTechnology.new(units: 5, buffer: technology.composite_value, type: "b")
          ]
        end

        let(:size) { 3 }

        it 'buffers are spread out nicely' do
          # Make sure the buffers are spread out nicely
          expect(partitioner.map(&:units)).to eq([4, 3, 3])
        end

        it 'associates have the same units as the attached buffer' do
          # Make sure the numbers are correct
          expect(partitioner.map{|t| t.associates.map(&:units) }).to eq(
            [[4,4], [3,3], [3,3]])
        end
      end
    end
  end
end
