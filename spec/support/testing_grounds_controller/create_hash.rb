module TestingGroundsControllerTest
  def self.create_hash(topology_id, market_model_id)
    {
      "testing_ground" => {
        "name"=>"A les",
        "parent_scenario_id"=>"",
        "scenario_id"=>"",
        "market_model_id" => market_model_id,
        "topology_id" => topology_id,
        "technology_profile" => "[]"
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
