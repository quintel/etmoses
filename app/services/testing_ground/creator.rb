class TestingGround::Creator
  def initialize(params)
    @params = params
  end

  def create
    @testing_ground = TestingGround.new(@params)
    @testing_ground.parent_scenario_id = parent_scenario_id
    @testing_ground.save
    @testing_ground
  end

  private

    def parent_scenario_id
      begin
        et_scenario = RestClient.get(scenario_url)
        JSON.parse(et_scenario)['template']
      rescue RestClient::ResourceNotFound
        nil
      end
    end

    def scenario_url
      [Export::API_BASE, @testing_ground.scenario_id].join("/")
    end
end
