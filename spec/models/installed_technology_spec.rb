require 'rails_helper'

RSpec.describe InstalledTechnology do
  describe '#exists?' do
    it 'returns false when :type is set to a non-existent technology' do
      expect(InstalledTechnology.new(type: 'nope')).to_not be_exists
    end

    it 'returns true when :type is not set' do
      expect(InstalledTechnology.new).to be_exists
    end

    it 'returns true when :type is set to a real technology' do
      create(:technology, key: 'tech_one')
      expect(InstalledTechnology.new(type: 'tech_one')).to be_exists
    end
  end

  describe '#technology' do
    it 'raises ActiveRecord::RecordNotFound when no such tech exists' do
      expect { InstalledTechnology.new(type: 'nope').technology }.
        to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns a generic tech when :type is not set' do
      lib = InstalledTechnology.new.technology

      expect(lib).to be_a(Technology)
      expect(lib.key).to eq('generic')
    end

    it 'returns the correct tech when :type is set' do
      create(:technology, key: 'tech_one')
      lib = InstalledTechnology.new(type: 'tech_one').technology

      expect(lib).to be_a(Technology)
      expect(lib.key).to eq('tech_one')
    end
  end # technology
end # InstalledTechnology
