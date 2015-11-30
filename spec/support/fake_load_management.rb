module FakeLoadManagement
  def self.topology_graph
    { "name"=>"HV",
      "children"=>[{
        "name"=>"CONGESTED_END_POINT_1",
        "capacity"=>1.0
      }]
    }
  end

  def self.caching_graph(size = 1)
    { "name"=>"HV",
      "children"=>(size.times.map { |i|
        { "name"=>"CONGESTED_END_POINT_#{i}",
          "capacity"=>100.0,
          "load" => [0.0] * 8760 }
      })
    }
  end

  def self.strategies(options = {})
    FactoryGirl.create(:selected_strategy).attributes.except("id", "testing_ground_id")
                                          .merge(options.stringify_keys)
  end
end
