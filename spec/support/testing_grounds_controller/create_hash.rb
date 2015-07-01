module TestingGroundsControllerTest
  def self.create_hash
    {
      "testing_ground" => {
        "name"=>"",
        "parent_scenario_id"=>"",
        "scenario_id"=>"",
        "topology_attributes"=>{"graph"=>"---\r\nname: HV Network\r\nchildren:\r\n- name: MV Network\r\n  children:\r\n  - name: \"LV #1\"\r\n  - name: \"LV #2\"\r\n  - name: \"LV #3\"\r\n"},
        "technology_profile"=>'{"LV #1":[{"node":"LV #1","type":"households_solar_pv_solar_radiation","name":"Residential PV panel","units":"38","capacity":"-1.5","profile":"solar_pv_zwolle"},{"node":"LV #1","type":"transport_car_using_electricity","name":"Electric car","units":"7","capacity":"3.7","profile":"ev_profile_11_3.7_kw"}],"LV #2":[{"node":"LV #2","type":"households_solar_pv_solar_radiation","name":"Residential PV panel","units":"38","capacity":"-1.5","profile":"solar_pv_zwolle"},{"node":"LV #2","type":"transport_car_using_electricity","name":"Electric car","units":"7","capacity":"3.7","profile":"ev_profile_11_3.7_kw"}],"LV #3":[{"node":"LV #3","type":"households_solar_pv_solar_radiation","name":"Residential PV panel","units":"37","capacity":"-1.5","profile":"solar_pv_zwolle"},{"node":"LV #3","type":"transport_car_using_electricity","name":"Electric car","units":"7","capacity":"3.7","profile":"ev_profile_11_3.7_kw"}]}'
      },
      "public" => "false",
      "js"=>{"technologies_as"=>"yaml"},
      "differentiation"=>"min",
      "commit"=>"Create Testing ground"
    }
  end
end
