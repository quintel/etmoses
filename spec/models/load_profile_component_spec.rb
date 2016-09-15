require 'rails_helper'

RSpec.describe LoadProfileComponent do
  it 'is not a valid load curve' do
    load_curve = LoadProfileComponent.new

    expect(load_curve.valid?).to eq(false)
  end

  it 'valid load curve' do
    load_curve = LoadProfileComponent.new
    load_curve.curve = fixture_file_upload('data/curves/one.csv', 'text/csv')
    load_curve.curve_type = 'Inflexible'

    expect(load_curve.valid?).to eq(true)
  end

  context 'with a wrong-length curve' do
    it 'valid load curve' do
      load_curve = LoadProfileComponent.new
      load_curve.curve = fixture_file_upload('technology_profile.csv', 'text/csv')
      load_curve.curve_type = 'Inflexible'

      expect(load_curve.errors_on(:curve))
        .to include('must have 35,040 values, but the uploaded file has 10')
    end
  end

  context 'with invalid UTF-8 data' do
    it 'is not valid' do
      load_curve = LoadProfileComponent.new(
        curve: fixture_file_upload('data/curves/invalid-utf8.csv', 'text/csv'),
        curve_type: 'Inflexible'
      )

      expect(load_curve.errors_on(:curve))
        .to include('contains invalid data; the curve should contain ' \
                    'only numbers, one on each line')
    end
  end
end
