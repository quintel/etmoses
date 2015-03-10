require 'rails_helper'

RSpec.describe Library::Technology do
  context 'with two technologies in the data/technologies dir' do
    it 'loads two technologies' do
      expect(Library::Technology.all.length).to eq(3)
    end

    it 'assigns the first technology' do
      expect { Library::Technology.find('tech_one') }.to_not raise_error
    end

    it 'assigns the second technology' do
      expect { Library::Technology.find('tech_two') }.to_not raise_error
    end

    it 'raises an error when finding a non-existent technology' do
      expect { Library::Technology.find('invalid') }.to raise_error
    end
  end # with two technologies in the data/technologies dir
end # Library::Technology
