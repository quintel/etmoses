require 'rails_helper'

RSpec.describe TestingGround::Calculator do
  let(:testing_ground) { FactoryGirl.create(:testing_ground) }

  before do
    allow(Settings.cache).to receive(:networks).and_return(true)
  end

  it 'sets a testing ground delayed job' do
    TestingGround::Calculator.new(testing_ground, {}).calculate

    expect(Delayed::Job.count).to eq(1)
  end

  it "should calculate when the 'testing_ground_delayed_job' is still present but the delayed job isn't" do
    TestingGroundDelayedJob.create!(testing_ground: testing_ground, job_type: 'basic', job_id: 0)
    TestingGround::Calculator.new(testing_ground, {}).calculate

    expect(Delayed::Job.count).to eq(1)
  end

  context 'with a fresh cache' do
    before do
      NetworkCache::Writer.from(testing_ground).write([
        Network::Builders.for(:electricity).build({
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
        }),
        Network::Builders.for(:gas).build({})
      ])
    end

    let(:cache) do
      TestingGround::Calculator.new(testing_ground, {}).calculate
    end

    it 'is not pending calculation' do
      expect(cache).to_not have_key(:pending)
    end

    it 'fetches the electricity network' do
      expect(cache).to have_key(:networks)
      expect(cache[:networks]).to have_key(:electricity)
    end

    it 'fetches the gas network' do
      expect(cache).to have_key(:networks)
      expect(cache[:networks]).to have_key(:gas)
    end
  end
end
