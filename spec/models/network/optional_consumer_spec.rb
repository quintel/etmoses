require 'rails_helper'

RSpec.describe Network::OptionalConsumer do
  let(:installed) { InstalledTechnology.new(capacity: profile.first, behavior: 'optional') }
  let(:tech)      { Network::Technology.from_installed(installed, profile) }
  let(:profile)   { [2.0] }

  it 'sets the capacity' do
    expect(tech.capacity).to eq(2.0)
  end

  it 'is not a producer' do
    expect(tech).to_not be_producer
  end

  it 'is a consumer' do
    expect(tech).to be_consumer
  end

  it 'is not storage' do
    expect(tech).to_not be_storage
  end

  it 'has reads conditional consumption from the profile' do
    expect(tech.conditional_consumption_at(0)).to eq(2.0)
  end

  it 'has has no mandatory consumption' do
    expect(tech.mandatory_consumption_at(0)).to be_zero
  end

  it 'has no production' do
    expect(tech.production_at(0)).to be_zero
  end
end
