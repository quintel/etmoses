module TestingGroundsControllerTest
  def self.show_hash
    {
      "graph"=>{"name"=>"hv", "children"=>[{"name"=>"mv", "children"=>[{"name"=>"lv1", "children"=>[], "capacity"=>nil, "load"=>[0.8999999999999999]}, {"name"=>"lv2", "children"=>[], "capacity"=>nil, "load"=>[3.3000000000000003]}], "capacity"=>nil, "load"=>[4.2]}], "capacity"=>nil, "load"=>[4.2]
      },
      "technologies"=>{
        "lv1"=>[{"name"=>"One", "type"=>"generic", "behavior"=>nil, "profile"=>nil, "load"=>1.2, "capacity"=>nil, "demand"=>nil, "volume"=>nil, "units"=>1.0, "concurrency"=>nil}, {"name"=>"Two", "type"=>"generic", "behavior"=>nil, "profile"=>nil, "load"=>-0.3, "capacity"=>nil, "demand"=>nil, "volume"=>nil, "units"=>1.0, "concurrency"=>nil}],
        "lv2"=>[{"name"=>"Three", "type"=>"generic", "behavior"=>nil, "profile"=>nil, "load"=>3.2, "capacity"=>nil, "demand"=>nil, "volume"=>nil, "units"=>1.0, "concurrency"=>nil}, {"name"=>"Four", "type"=>"generic", "behavior"=>nil, "profile"=>nil, "load"=>0.1, "capacity"=>nil, "demand"=>nil, "volume"=>nil, "units"=>1.0, "concurrency"=>nil}]
      }
    }
  end
end
