require 'rails_helper'

module Market::Foundations
  RSpec.describe InstantaneousLoad do
    let(:node) { Network::Node.new(:thing, load: [1, 2, 3, 9, 8, 7]) }

    it 'returns the node load for each point in time' do
      expect(InstantaneousLoad.call(node)).to eq([1, 2, 3, 9, 8, 7])
    end
  end
end
