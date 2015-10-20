require 'rails_helper'

RSpec.describe MarketModel do
  it { expect(subject).to validate_presence_of(:name) }

  context 'with an irregular-length measure' do
    before do
      subject.interactions = [{
        'tariff_type'      => nil,
        'tariff'           => 1.0,
        'foundation'       => 'kw_max',
        'stakeholder_from' => 'one',
        'stakeholder_to'   => 'two'
      }]
    end

    it 'should have an error when using a curve tariff' do
      subject.interactions.first['tariff_type'] = 'curve'

      expect(subject.errors_on(:base)).to include(
        "You may not use a curve tariff with the " \
        "'monthly maximum kW load' measure."
      )
    end

    it 'should have an error when using the merit tariff' do
      subject.interactions.first['tariff_type'] = 'merit'

      expect(subject.errors_on(:base)).to include(
        "You may not use a merit tariff with the " \
        "'monthly maximum kW load' measure."
      )
    end

    it 'should have no error when using a fixed tariff' do
      subject.interactions.first['tariff_type'] = 'fixed'
      expect(subject.errors_on(:base)).to be_blank
    end
  end # with an irregular-length measure

  context 'with a regular-length measure' do
    before do
      subject.interactions = [{
        'tariff_type'      => nil,
        'tariff'           => 1.0,
        'foundation'       => 'load',
        'stakeholder_from' => 'one',
        'stakeholder_to'   => 'two'
      }]
    end

    it 'should have an no errors when using a curve tariff' do
      subject.interactions.first['tariff_type'] = 'curve'
      expect(subject.errors_on(:base)).to be_blank
    end

    it 'should have an error when using the merit tariff' do
      subject.interactions.first['tariff_type'] = 'merit'
      expect(subject.errors_on(:base)).to be_blank
    end

    it 'should have no error when using a fixed tariff' do
      subject.interactions.first['tariff_type'] = 'fixed'
      expect(subject.errors_on(:base)).to be_blank
    end
  end # with a regular-length measure
end
