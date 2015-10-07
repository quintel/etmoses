require 'rails_helper'

RSpec.describe NetworkCache::Writer do
  let(:curve){
    35040.times.map{|t| rand(0.0...0.5) }
  }

  let(:testing_ground){ FactoryGirl.create(:testing_ground) }

  it 'writes to cache' do
    write_curve = curve;
    NetworkCache::Writer.from(testing_ground).write('test-key', write_curve)

    expect(NetworkCache::Reader.from(testing_ground).read('test-key')).to eq(write_curve)
  end

  it 'writes strategies to a separate cache' do
    write_curve = curve;
    NetworkCache::Writer.from(testing_ground, { saving_base_load: true })
           .write('test-key', write_curve)

    expect(NetworkCache::Reader.from(testing_ground, { saving_base_load: true  })
           .read('test-key')).to eq(write_curve)
  end
end
