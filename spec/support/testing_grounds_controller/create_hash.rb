module TestingGroundsControllerTest
  def self.create_hash(topology_template, market_model_template)
    {
      "testing_ground" => {
        "name"=>"A les",
        "parent_scenario_id"=>"2",
        "scenario_id"=>"1",
        "market_model_attributes" => {
          "interactions" => market_model_template.interactions.to_json,
          "market_model_template_id" => market_model_template.id
        },
        "topology_attributes" => {
          "graph" => topology_template.graph.to_json,
          "topology_template_id" => topology_template.id
        },
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
