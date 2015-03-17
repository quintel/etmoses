require 'rails_helper'

RSpec.describe Import do
  let(:import) do
    Import.new(topology_id: topology.id).tap do |import|
      allow(import).to receive(:response).and_return(response)
    end
  end

  let(:topology)       { create(:topology) }
  let(:testing_ground) { import.testing_ground }

  def build_response(techs)
    techs.each_with_object({}) do |(key, units), data|
      data[key] = { 'number_of_units' => { 'future' => units } }
    end
  end

  context 'with no existing topology' do
    let(:response) { build_response('tech_one' => 1.0) }

    it 'builds a new topology' do
      expect(testing_ground.topology).to be_new_record
    end

    it 'uses the default graph layout' do
      expect(testing_ground.topology.graph).to_not be_blank
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
  end # with five coal heaters and three gas heaters
end # describe Import
