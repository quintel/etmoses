require 'rails_helper'

RSpec.describe TestingGround::Calculator do
  let(:testing_ground){ FactoryGirl.create(:testing_ground) }

  it 'sets a testing ground delayed job' do
    TestingGround::Calculator.new(testing_ground, {}).calculate

    expect(TestingGroundDelayedJob.count).to eq(1)
  end

  it 'fetches the cache if it has one' do
    NetworkCache::Writer.from(testing_ground).write(TreeToGraph.convert({
      name: 'hv',
      load: [0.0] * 8760,
      children: [{
        name: 'mv',
        load: [0.0] * 8760,
        children: [
          { name: 'lv1', load: [0.0] * 8760 },
          { name: 'lv2', load: [0.0] * 8760 }
        ]
      }]
    }))

    expect(TestingGround::Calculator.new(testing_ground, {}).calculate).to have_key(:graph)
  end
end
