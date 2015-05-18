def stub_et_engine_request
  stub_request(:post,
    "http://beta.et-engine.com/api/v3/scenarios/1/converters/stats").
    with(body: "{\"keys\":[\"magical_technology\"]}",
         headers: {'Content-Type'=>'application/json'}).
    to_return(status: 200,
              body: JSON.dump({
                nodes: {
                  magical_technology: {
                    load: 1.0
                  }
                }
              }) )
end

def stub_scenario_request
  stub_request(:get, "http://beta.et-engine.com/api/v3/scenarios/1").
       with(headers: {'Accept'=>'*/*; q=0.5, application/xml',
                      'Accept-Encoding'=>'gzip, deflate'}).
       to_return(status: 200,
                 body: JSON.dump({template: 2, scaling: {value: 1}}))
end


def stub_et_engine_templates
   stub_request(:get, "http://et-engine.com/api/v3/scenarios/templates").
      with(headers: {'Accept'=>'*/*; q=0.5, application/xml',
                     'Accept-Encoding'=>'gzip, deflate',
                     'User-Agent'=>'Ruby'}).
      to_return(status: 200, body: JSON.dump({}), headers: {})
end
