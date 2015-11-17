module TestingGroundsControllerTest
  def self.create_hash(topology_id, market_model_id)
    {
      "testing_ground" => {
        "name"=>"A les",
        "parent_scenario_id"=>"",
        "scenario_id"=>"",
        "market_model_id" => market_model_id,
        "topology_id" => topology_id,
        "technology_profile"=>'{"LV #1":[{"node":"LV #1","type":"households_solar_pv_solar_radiation","name":"Residential PV panel","units":"38","capacity":"-1.5","profile":"solar_pv_zwolle"},{"node":"LV #1","type":"transport_car_using_electricity","name":"Electric car","units":"7","capacity":"3.7","profile":"ev_profile_11_3.7_kw"}],"LV #2":[{"node":"LV #2","type":"households_solar_pv_solar_radiation","name":"Residential PV panel","units":"38","capacity":"-1.5","profile":"solar_pv_zwolle"},{"node":"LV #2","type":"transport_car_using_electricity","name":"Electric car","units":"7","capacity":"3.7","profile":"ev_profile_11_3.7_kw"}],"LV #3":[{"node":"LV #3","type":"households_solar_pv_solar_radiation","name":"Residential PV panel","units":"37","capacity":"-1.5","profile":"solar_pv_zwolle"},{"node":"LV #3","type":"transport_car_using_electricity","name":"Electric car","units":"7","capacity":"3.7","profile":"ev_profile_11_3.7_kw"}]}'
      },
      "public" => "false",
      "js"=>{"technologies_as"=>"yaml"},
      "differentiation"=>"min",
      "commit"=>"Create Testing ground"
    }
  end

  def self.create_hash_with_file(topology_id, market_model_id, file)
    testing_ground_hash = self.create_hash(topology_id, market_model_id)
    testing_ground_hash['testing_ground']['technology_profile_csv'] = file
    testing_ground_hash
  end
end
