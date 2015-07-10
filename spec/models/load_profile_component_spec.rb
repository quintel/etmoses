require 'rails_helper'

RSpec.describe LoadProfileComponent do
  it 'is not a valid load curve' do
    load_curve = LoadProfileComponent.new

    expect(load_curve.valid?).to eq(false)
  end

  it 'valid load curve' do
    load_curve = LoadProfileComponent.new
    load_curve.curve = fixture_file_upload('technology_profile.csv', 'text/csv')
    load_curve.curve_type = 'Inflexible'

    expect(load_curve.valid?).to eq(true)
  end
end
