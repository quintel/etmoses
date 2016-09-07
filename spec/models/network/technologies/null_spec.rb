require 'rails_helper'

RSpec.describe Network::Technologies::Null do
  let(:tech) do
    Network::Technologies::Null.new(build(:installed_tv), [1.0, 1.0])
  end

  it 'has no production' do
    expect(tech.production_at(0)).to be_zero
  end

  it 'has no mandatory consumption' do
    expect(tech.mandatory_consumption_at(0)).to be_zero
  end

  it 'has no conditional consumption' do
    expect(tech.conditional_consumption_at(0, nil)).to be_zero
  end

  it 'has no load' do
    expect(tech.load_at(0)).to be_zero
  end
end
