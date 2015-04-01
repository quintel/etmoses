require 'rails_helper'

RSpec.describe Import do
  let(:import) do
    Import.new(topology_id: topology.id, scenario_id: 1337).tap do |import|
      allow(import).to receive(:response).and_return(response)
    end
  end

  let(:topology)       { create(:topology) }
  let(:testing_ground) { import.testing_ground }

  before do
    %w( tech_one tech_two ).each do |key|
      Technology.create!(key: key, import_from: 'electricity_output_capacity')
    end
  end

  def build_response(techs)
    techs.each_with_object({}) do |(key, units), data|
      data[key] = { 'number_of_units' => { 'future' => units } }
    end
  end

  def find_techs(tg, key)
    tg.technologies.to_h.values.flatten.select { |t| t.type == key }
  end

  context 'with no existing topology' do
    let(:response) { build_response('tech_one' => 1.0) }

    it 'builds a new topology' do
      expect(testing_ground.topology).to be_new_record
    end

    it 'uses the default graph layout' do
      expect(testing_ground.topology.graph).to_not be_blank
    end

    it 'saves the scenario ID on the testing ground' do
      expect(testing_ground.scenario_id).to eq(1337)
    end
  end # with no existing topology

  context 'with five coal heaters and three gas heaters' do
    let(:response) do
      build_response('tech_one' => 5.0,'tech_two' => 3.0)
    end

    it 'adds three coal heaters to LV #1' do
      expect(testing_ground.technologies['lv1'].select do |tech|
        tech['name'].match(/tech one/i)
      end.length).to eq(3)
    end

    it 'adds two coal heaters to LV #2' do
      expect(testing_ground.technologies['lv2'].select do |tech|
        tech['name'].match(/tech one/i)
      end.length).to eq(2)
    end

    it 'adds one gas heater to LV #1' do
      expect(testing_ground.technologies['lv1'].select do |tech|
        tech['name'].match(/tech two/i)
      end.length).to eq(1)
    end

    it 'adds two gas heaters to LV #2' do
      expect(testing_ground.technologies['lv2'].select do |tech|
        tech['name'].match(/tech two/i)
      end.length).to eq(2)
    end

    context 'when tech_one has two available load profiles' do
      let(:profile_one) { create(:load_profile, key: 'profile_one') }
      let(:profile_two) { create(:load_profile, key: 'profile_two') }

      before do
        PermittedTechnology.create!(
          technology: 'tech_one', load_profile: profile_one)

        PermittedTechnology.create!(
          technology: 'tech_one', load_profile: profile_two)
      end

      it 'assigns the profiles fairly to applicable technologies' do
        techs = find_techs(testing_ground, 'tech_one')

        expect(techs.select { |t| t.profile == 'profile_one' }.length).to eq(3)
        expect(techs.select { |t| t.profile == 'profile_two' }.length).to eq(2)
      end

      it 'does not assign the profiles to inapplicable technologies' do
        techs = find_techs(testing_ground, 'tech_two')

        expect(techs.select { |t| t.profile == 'profile_one' }.length).to eq(0)
        expect(techs.select { |t| t.profile == 'profile_two' }.length).to eq(0)
      end
    end # when tech_one has two available load profiles

    context 'importing the electricity_output_capacity attribute' do
      let(:response) { { 'tech_one' => {
        'number_of_units' => { 'future' => 3 },
        'electricity_output_capacity' => { 'future' => 0.02 }
      } } }

      let(:tech) { find_techs(testing_ground, 'tech_one').first }

      it 'saves the attribute value as "capacity"' do
        expect(tech.capacity).to be
      end

      it 'converts the value to KW' do
        expect(tech.capacity).to eq(20.0)
      end
    end # importing the electricity_output_capacity attribute

    context 'importing the input_capacity attribute' do
      before do
        Technology.by_key('tech_one').update_attributes!(
          import_from: 'input_capacity'
        )
      end

      let(:response) { { 'tech_one' => {
        'number_of_units' => { 'future' => 3 },
        'input_capacity' => { 'future' => 0.04 }
      } } }

      let(:tech) { find_techs(testing_ground, 'tech_one').first }

      it 'saves the attribute value as "capacity"' do
        expect(tech.capacity).to be
      end

      it 'converts the value to KW' do
        expect(tech.capacity).to eq(40.0)
      end
    end # importing the input_capacity attribute

    context 'importing the demand attribute' do
      before do
        Technology.by_key('tech_one').update_attributes!(
          import_from: 'demand'
        )
      end

      let(:response) { { 'tech_one' => {
        'number_of_units' => { 'future' => 3 },
        'demand' => { 'future' => 300.0 }
      } } }

      let(:tech) { find_techs(testing_ground, 'tech_one').first }

      it 'saves the attribute value as "demand"' do
        expect(tech.demand).to be
      end

      it 'divides the value by the number of units, converting to kwh' do
        expect(tech.demand).to be_within(1e-9).of(100.0 / 3.6)
      end
    end # importing the demand attribute
  end # with five coal heaters and three gas heaters
end # describe Import
