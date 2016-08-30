require 'rails_helper'
require_relative 'shared_reserve_specs'

RSpec.describe Network::Reserve do
  let(:reserve) { described_class.new }

  it 'starts empty' do
    expect(reserve.at(0)).to be_zero
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

  include_examples 'a network reserve'
end
