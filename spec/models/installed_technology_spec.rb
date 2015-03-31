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
      expect(InstalledTechnology.new(type: 'tech_one')).to be_exists
    end
  end

  describe '#library' do
    it 'raises ActiveRecord::RecordNotFound when no such tech exists' do
      expect { InstalledTechnology.new(type: 'nope').library }.
        to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns a generic tech when :type is not set' do
      lib = InstalledTechnology.new.library

      expect(lib).to be_a(Library::Technology)
      expect(lib.key).to eq('generic')
    end

    it 'returns the correct tech when :type is set' do
      lib = InstalledTechnology.new(type: 'tech_one').library

      expect(lib).to be_a(Library::Technology)
      expect(lib.key).to eq('tech_one')
    end
  end # library
end # InstalledTechnology
