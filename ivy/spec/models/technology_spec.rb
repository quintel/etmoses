require 'rails_helper'

RSpec.describe Technology do
  context 'with two technologies in the data/technologies dir' do
    it 'loads two technologies' do
      expect(Technology.all.length).to eq(2)
    end

    it 'assigns the first technology' do
      expect { Technology.find('tech_one') }.to_not raise_error
    end

    it 'assigns the second technology' do
      expect { Technology.find('tech_two') }.to_not raise_error
    end

    it 'raises an error when finding a non-existent technology' do
      expect { Technology.find('invalid') }.to raise_error
    end
  end # with two technologies in the data/technologies dir

  context 'when a technology has two permitted load profiles' do
    it 'returns two profiles' do
      expect(Technology.find('tech_one').profiles.keys.sort).
        to eq(%w( agriculture_chp total_demand ))
    end
  end # when a technology has two permitted load profiles

  context 'when a technology specified a load profile as a glob' do
    it 'returns all matching profiles' do
      expect(Technology.find('tech_two').profiles.keys.sort).
        to eq(%w( agriculture_chp buildings_chp total_demand ))
    end
  end # when a technology specified a load profile as a glob
end # Technology
