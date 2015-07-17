require 'rails_helper'

module Market
  RSpec.describe Variant do
    let(:variant) do
      Variant.new do
        market = Graph.new
        market.add(Stakeholder.new(:one))
        market
      end
    end

    describe '#call' do
      it 'creates procs' do
        expect(variant.call(Stakeholder.new(:one))).to respond_to(:call)
      end

      it 'returns the desired value from the proc' do
        expect(variant.call(Stakeholder.new(:one)).call.key).to eq(:one)
      end
    end # call
  end
end
