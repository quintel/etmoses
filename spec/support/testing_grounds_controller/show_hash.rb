module TestingGroundsControllerTest
  def self.show_hash
    {
      "graph"=>{
        "name"=>"hv",
        "children"=>[{
          "name"=>"mv",
          "children"=>[
            { "name"=>"lv1", "children"=>[], "capacity"=>nil, "load"=>[0.8999999999999999] },
            { "name"=>"lv2", "children"=>[], "capacity"=>nil, "load"=>[3.3000000000000003]}
          ],
          "capacity"=>nil,
          "load"=>[4.2]
        }],
        "capacity"=>nil,
        "load"=>[4.2]
      }
    }
  end
end
