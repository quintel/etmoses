def stub_et_engine_scenario_create_request(preset_id = 2)
  stub_request(:post, "https://beta.et-engine.com/api/v3/scenarios").with(
    :body => {
      "scenario"=>{"scenario_id"=>preset_id.to_s,
      "descale"=>"true"}
    },
    :headers => {
      'Accept'=>'application/json',
      'Accept-Encoding'=>'gzip, deflate',
      'Content-Type'=>'application/x-www-form-urlencoded'
    }
  ).to_return(:status => 200, :body => JSON.dump({id: 2}), :headers => {})
end

def stub_et_engine_scenario_update_request(id = 2)
  stub_request(:put, "https://beta.et-engine.com/api/v3/scenarios/#{id}").with(
    :body => {
      "autobalance"=>"true",
      "force_balance"=>"true",
      "scenario"=>{
        "title"=>"My Testing Ground",
        "user_values"=>{
          "households_solar_pv_solar_radiation_market_penetration"=>"100.0",
          "transport_car_using_electricity_share"=>"100.0"
        }
      }
    },
    :headers => {
      'Accept'=>'application/json',
      'Accept-Encoding'=>'gzip, deflate',
      'Content-Type'=>'application/x-www-form-urlencoded'
    }
  ).to_return(:status => 200, :body => JSON.dump({}), :headers => {})
end

def stub_et_engine_scenario_inputs_request(id = 2)
  url  = "https://beta.et-engine.com/api/v3/scenarios/#{id}/inputs"
  json = YAML.load_file(Rails.root.join('spec/fixtures/responses/inputs.yml'))

  stub_request(:get, url).with(:headers => {
    'Accept'          => 'application/json',
    'Accept-Encoding' => 'gzip, deflate',
    'Content-Type'    => 'application/json'
  }).to_return(:status => 200, :body => JSON.dump(json), :headers => {})
end

def stub_et_engine_request(keys = ['magical_technology'])
  nodes = Hash[keys.map do |key|
    [key, { load: 1.0, technical_lifetime: { present: 2, future: 2 } }]
  end]

  stub_request(:post,
    "https://beta.et-engine.com/api/v3/scenarios/1/converters/stats").
    with(body: {"keys"=>keys},
         headers: {
          'Accept'=>'application/json',
          'Accept-Encoding'=>'gzip, deflate',
          'Content-Type'=>'application/x-www-form-urlencoded'
         }).
    to_return(status: 200, body: JSON.dump(nodes: nodes))
end

def stub_scenario_request(id = 1)
  stub_request(:get, "https://beta.et-engine.com/api/v3/scenarios/#{id}").
       with(headers: {'Accept'=>'application/json',
                      'Accept-Encoding'=>'gzip, deflate'}).
       to_return(status: 200,
                 body: JSON.dump({id: id, template: 2, scaling: {value: 1}}))
end


def stub_et_engine_templates
   stub_request(:get, "https://et-engine.com/api/v3/scenarios/templates").
      with(headers: {'Accept'=>'*/*; q=0.5, application/xml',
                     'Accept-Encoding'=>'gzip, deflate'}).
      to_return(status: 200, body: JSON.dump({}), headers: {})
end

def stub_et_gquery(gqueries)
  stub_request(:put, "https://beta.et-engine.com/api/v3/scenarios/1").
    with(body: { "gqueries"=> gqueries.keys.map(&:to_s) },
         headers: {
          'Accept'=>'application/json',
          'Accept-Encoding'=>'gzip, deflate',
          'Content-Type'=>'application/x-www-form-urlencoded'
         }).
    to_return(
      status: 200,
      body: JSON.dump({
       "scenario"=> {
         "id"=>123,
         "title"=>"Martinus scenario run",
         "area_code"=>"nl",
         "start_year"=>2012,
         "end_year"=>2030,
         "url"=>"https://et-engine.com/api/v3/scenarios/123",
         "ordering"=>nil,
         "display_group"=>nil,
         "source"=>nil,
         "template"=>nil,
         "created_at"=>"2010-06-14T17:23:00.000+02:00",
         "scaling"=>nil
        },
        "gqueries"=> gqueries
      }),
      headers: {}
    )
end
