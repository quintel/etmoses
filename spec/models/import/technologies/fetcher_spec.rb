require 'rails_helper'

RSpec.describe Import::Technologies::Fetcher do
 let(:et_engine_technology_keys) { [] }

  let(:importable_gqueries) {
    [
      "electric_cars_additional_costs",
      "etmoses_electricity_base_load_demand",
      "etmoses_hot_water_buffer_demand",
      "etmoses_space_heating_buffer_demand",
      "number_of_buildings",
      "present_demand_in_source_of_electricity_in_buildings",
      "share_of_p2h_in_hot_water_produced_in_households"
      #"et_test_capacity",
      #"et_test_capacity",
      #"et_test_heat_production",
      #"etmoses_electricity_base_load_demand",
      #"etmoses_hot_water_buffer_demand",
      #"etmoses_space_heating_buffer_demand",
      #"number_of_buildings",
      #"present_demand_in_source_of_electricity_in_buildings"
    ].sort
  }

  let(:et_technologies_result) {
    YAML.load(File.read("#{ Rails.root }/spec/fixtures/data/et_engine_technologies/default.yml"))
  }

  let!(:stub_etm_scenario_technologies) {
    stub_request(:post, "#{ Settings.etengine_host }/api/v3/scenarios/2/converters/stats").
      with(:body => { },
           :headers => { 'Accept'=>'application/json', }
          ).to_return(
            :status => 200,
            :body => JSON.dump(et_technologies_result),
            :headers => {})
  }

  let(:gquery_answer) {
    { 'gqueries' => {
      "etmoses_electricity_base_load_demand" => {
        'present' => 1, 'future' => 2 },
      "etmoses_space_heating_buffer_demand" => {
        'present' => 1, 'future' => 2 },
      "etmoses_hot_water_buffer_demand" => {
        'present' => 1, 'future' => 2 },
      "present_demand_in_source_of_electricity_in_buildings" => {
        'present' => 1, 'future' => 2 },
      "number_of_buildings" => {
        'present' => 1, 'future' => 2 },
      "number_of_residences" => {
        'present' => 1, 'future' => 2 },
      "electric_cars_additional_costs" => {
        'present' => 1, 'future' => 2 }
    } }
  }

  let!(:stub_gqueries) {
    stub_request(:put, "#{ Settings.etengine_host }/api/v3/scenarios/2").
         with(:body => {"gqueries"=> importable_gqueries },
              :headers => { 'Accept'=>'application/json', }
             ).to_return(
              :status => 200,
              :body => JSON.dump(gquery_answer),
              :headers => {})
  }

  it "builds a range of technologies" do
    fetcher = Import::Technologies::Fetcher.new(
      id: 2, scaling: { 'value' => 1, 'area_attribute' => 'number_of_residences' })

    expect(fetcher).to receive(:keys).and_return(et_engine_technology_keys)

    technologies = fetcher.fetch.map{ |t| t['type'] }

    expect(technologies).to include('base_load')
    expect(technologies).to include('base_load_buildings')
    expect(technologies).to include('buffer_space_heating')
  end
end
