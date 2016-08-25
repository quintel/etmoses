require 'rails_helper'

RSpec.describe HeatSourceListDecorator do
  let(:heat_source) do
    FactoryGirl.create(:heat_source_list, asset_list: heat_source_list)
  end

  let(:decorated) do
    HeatSourceListDecorator.new(heat_source).decorate
  end

  context 'with a heat source' do
    let(:heat_source_list) do
      YAML.load(
        File.read("#{Rails.root}/spec/fixtures/data/heat_source_lists/default.yml")
      )
    end

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
        expect(chp_biogas.units).to eq(1.0)
      end
    end
  end # with a heat source

  context "with a heat source that doesn't exist" do
    let(:heat_source_list) { [{ key: 'invalid' }] }

    it 'raises an ActiveRecord::RecordNotFound error' do
      expect{ decorated }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end # with a heat source that doesn't exist
end
