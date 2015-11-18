module TestingGroundsControllerTest
  def self.update_hash(profile)
    { "scenario_id"=>"405671",
      "name"=>"2015-08-02 - Test123",
      "technology_profile"=> JSON.dump({
        "lv1"=>[
          {
            "node"=>"lv1",
            "name"=>"Residential PV panel",
            "type"=>"households_solar_pv_solar_radiation",
            "profile"=>profile.id,
            "capacity"=>"-1.5",
            "storage"=>"",
            "units"=>"38.0"
          }
        ],
        "lv2"=>[],
        "lv3"=>[]
      })
    }
  end
end
