require 'rails_helper'

RSpec.describe NetworkCache::Reader do
  let(:curve){
    35040.times.map do |i|
      rand(0.0...0.5)
    end
  }

  let(:testing_ground){ FactoryGirl.create(:testing_ground) }

  it "reads data from cache" do
    write_curve = curve

    NetworkCache::Writer.from(testing_ground).write('test-key', write_curve)

    expect(NetworkCache::Reader.from(testing_ground).read('test-key')).to eq(write_curve)
  end

  it "doesn't read from cache" do
    expect{ NetworkCache::Reader.from(testing_ground).read('non-existing-test-key') }.to raise_error(Errno::ENOENT)
  end
end
