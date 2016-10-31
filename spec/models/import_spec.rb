require 'rails_helper'

RSpec.describe Import do
  let(:import) do
    allow_any_instance_of(Import::Technologies::Fetcher)
      .to receive(:response).and_return(response)

    allow_any_instance_of(Import::Technologies::Fetcher)
      .to receive(:gqueries).and_return({})

    Import.new(topology_template_id: topology_template.id, scenario_id: 1337).tap do |import|
      allow(import).to receive(:parent_scenario_id).and_return(nil)
    end
  end

  let(:topology_template) { FactoryGirl.create(:topology_template) }
  let(:testing_ground)    { import.testing_ground }
  let!(:etm_scenario)     { stub_scenario_request(1337) }

  before do
    %w(tech_one tech_two).each do |key|
      Technology.create!(
        key: key,
        carrier: 'electricity',
        defaults: Hash.new(0),
        importable_attributes: [
          'electricity_output_capacity'
        ]
      )
    end
  end

  def build_response(techs)
    techs.each_with_object({}) do |(key, units), data|
      data[key] = { 'number_of_units' => { 'future' => units } }
    end
  end

  def find_techs(tg, key)
    tg.technology_profile.list.values.flatten.select do |t|
      t.type == key
    end
  end

  context 'with no existing topology' do
    let(:response) { build_response('tech_one' => 1.0) }

    it 'uses the default graph layout' do
      expect(testing_ground.topology.graph).to_not be_blank
    end

    it 'saves the scenario ID on the testing ground' do
      expect(testing_ground.scenario_id).to eq(1337)
    end
  end # with no existing topology

  context 'with five coal heaters and three gas heaters' do
    let(:response) do
      build_response('tech_one' => 5,'tech_two' => 3)
    end

    it 'adds three coal heaters' do
      expect(testing_ground.technology_profile.list["lv1"][0].units).to eq(3.0)
    end

    context 'when the ETE scenario has no parent' do
      it 'saves no parent scenario ID on the testing ground' do
        expect(testing_ground.parent_scenario_id).to be_nil
      end
    end

    context 'when the ETE scenario has a parent' do
      before do
        allow(import).to receive(:parent_scenario_id).and_return(42)
      end

      it 'saves no parent scenario ID on the testing ground' do
        expect(testing_ground.parent_scenario_id).to eq(42)
      end
    end

    context 'importing the electricity_output_capacity attribute' do
      let(:response) { { 'tech_one' => {
        'number_of_units' => { 'future' => 3 },
        'electricity_output_capacity' => { 'future' => 0.02 }
      } } }

      let(:tech) { find_techs(testing_ground, 'tech_one').first }

      before do
        technology = Technology.find_by_key!('tech_one')
        technology.importable_attributes = ['electricity_output_capacity']
      end

      it 'saves the attribute value as "capacity"' do
        expect(tech['capacity']).to be
      end

      it 'converts the value to KW' do
        expect(tech['capacity'].abs).to eq(20.0)
      end

      it 'imports the value as a negative (indicating production)' do
        expect(tech['capacity']).to be < 0
      end
    end # importing the electricity_output_capacity attribute

    context 'importing the input_capacity attribute' do
      before do
        technology = Technology.find_by_key!('tech_one')
        technology.importable_attributes = ['input_capacity']
      end

      let(:response) { { 'tech_one' => {
        'number_of_units' => { 'future' => 3 },
        'input_capacity' => { 'future' => 0.04 }
      } } }

      let(:tech) { find_techs(testing_ground, 'tech_one').first }

      it 'saves the attribute value as "capacity"' do
        expect(tech['capacity']).to be
      end

      it 'converts the value to KW' do
        expect(tech['capacity']).to eq(40.0)
      end
    end # importing the input_capacity attribute

    context 'importing the demand attribute' do
      before do
        technology = Technology.find_by_key!('tech_one')
        technology.importable_attributes = ['demand']
      end

      let(:response) { { 'tech_one' => {
        'number_of_units' => { 'future' => 3 },
        'demand' => { 'future' => 300.0 }
      } } }

      let(:tech) { find_techs(testing_ground, 'tech_one').first }

      it 'saves the attribute value as "demand"' do
        expect(tech['demand']).to be
      end

      it 'divides the value by the number of units, converting to kwh' do
        expect(tech['demand']).to be_within(1e-9).of(100.0 / 3.6)
      end
    end # importing the demand attribute
  end # with five coal heaters and three gas heaters

end # describe Import
