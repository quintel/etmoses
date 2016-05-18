require 'rails_helper'

RSpec.describe HeatSourceListDecorator do
  let(:heat_source_list) {
    YAML.load(
      File.read("#{Rails.root}/spec/fixtures/data/heat_source_lists/default.yml")
    )
  }

  let(:heat_source) {
    FactoryGirl.create(:heat_source_list, source_list: heat_source_list)
  }

  let(:decorated) {
    HeatSourceListDecorator.new(heat_source).decorate
  }

  it 'decorates a heat source list' do
    expect(decorated.size).to eq(3)
  end

  context 'chp biogas' do
    let(:chp_biogas) { decorated.detect do |tech|
      tech.key == 'households_collective_chp_biogas'
    end }

    it 'sets the correct name' do
      expect(chp_biogas.name).to eq('Biogas CHP households')
    end

    it 'sets the correct units' do
      expect(chp_biogas.units).to eq(0.4121683818119746)
    end
  end
end
