require 'rails_helper'

RSpec.describe TestingGround::TechnologyPartitioner do
  describe "non composite" do
    it 'partitions a technology' do
      technology = InstalledTechnology.new(units: 5)
      partitioner = TestingGround::TechnologyPartitioner.new(technology, 4).partition

      expect(partitioner.size).to eq(4)
      expect(partitioner.sum(&:units)).to eq(5)
    end
  end

  describe "composite" do
    let(:technology){
      InstalledTechnology.new(units: 10, composite: true, composite_value: 'buffer_1')
    }

    it 'partitions composite technologies with only one technology type' do
      technology.associates = [
        InstalledTechnology.new(units: 10, buffer: technology, type: 'a')
      ]

      partitioner = TestingGround::TechnologyPartitioner.new(technology, 3).partition

      expect(partitioner.map(&:units)).to eq([4, 3, 3])
      expect(partitioner.map{|t| t.associates.map(&:units) }.flatten).to eq([4, 3, 3])
    end

    it 'partitions composite technologies with only one technology type' do
      technology.associates = [
        InstalledTechnology.new(units: 10, buffer: technology, type: 'a'),
        InstalledTechnology.new(units: 4, buffer: technology, type: 'b')
      ]

      partitioner = TestingGround::TechnologyPartitioner.new(technology, 2).partition

      expect(partitioner.map(&:units)).to eq([5, 5])
      expect(partitioner.map{|t| t.associates.map(&:units) }).to eq([[5,2], [5,2]])
    end

    describe "uneven associates" do
      it 'partitions composite technologies' do
        technology.associates = [
          InstalledTechnology.new(units: 7, buffer: technology, type: 'a'),
          InstalledTechnology.new(units: 7, buffer: technology, type: 'b')
        ]

        partitioner = TestingGround::TechnologyPartitioner.new(technology, 2).partition

        expect(partitioner.last.associates.map(&:units)).to eq([3, 4])
        expect(partitioner.map(&:composite_value)).to eq(%w(buffer_1 buffer_2))
        expect(partitioner.map(&:associates).flatten.select{|t| t.type == 'a'}
               .sum(&:units)).to eq(7)
      end


      it 'partitions composite technologies' do
        technology.associates = [
          InstalledTechnology.new(units: 5, buffer: technology, type: "a"),
          InstalledTechnology.new(units: 5, buffer: technology, type: "b")
        ]

        partitioner = TestingGround::TechnologyPartitioner.new(technology, 3).partition

        # Make sure the buffers are spread out nicely
        expect(partitioner.map(&:units)).to eq([4, 3, 3])

        # Make sure the numbers are correct
        expect(partitioner.map{|t| t.associates.map(&:units) }).to eq([[2,2], [2,1], [1,2]])

        # Make sure that the initial units doesn't change
        #expect(partitioner.map(&:associates).flatten.select{|t| t.name == '1'}
        #       .sum(&:units)).to eq(5)
      end
    end
  end
end
