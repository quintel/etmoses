require 'rails_helper'

RSpec.describe NetworkCache::Validator do
  let(:testing_ground){ FactoryGirl.create(:testing_ground) }

  it 'validates the network cache' do
    expect(NetworkCache::Validator.from(testing_ground).valid?).to eq(false)
  end

  it 'validates the network cache' do
    testing_ground.topology.each_node do |node|
      NetworkCache::Writer.from(testing_ground).write(node[:name], [0.0] * 35040)
    end

    expect(NetworkCache::Validator.from(testing_ground).valid?).to eq(true)
  end

  it 'validates the network cache' do
    testing_ground.topology.each_node do |node|
      NetworkCache::Writer.from(testing_ground).write(node[:name], [0.0] * 35040)
    end

    expect(NetworkCache::Validator.from(testing_ground, {}).valid?(true)).to eq(false)
  end
end
