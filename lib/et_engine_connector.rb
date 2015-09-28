class EtEngineConnector
  #
  # Wrapper for EtEngine
  #

  ETM_URLS = {
    stats:     'http://%s/api/v3/scenarios/%d/converters/stats',
    scenario:  'http://%s/api/v3/scenarios/%d',
    scenarios: 'http://%s/api/v3/scenarios',
    merit:     'http://%s/api/v3/scenarios/%d/merit',
    inputs:    'http://%s/api/v3/scenarios/%d/inputs'
  }.freeze

  HEADERS = { content_type: :json, accept: :json }

  def initialize(params = {})
    @params = params
    @provider = TestingGround::IMPORT_PROVIDERS.first
  end

  def stats(scenario_id)
    url = ETM_URLS[:stats] % [@provider, scenario_id]

    et_api_request(:post, url, @params, HEADERS)
  end

  def scenario(scenario_id)
    url = ETM_URLS[:scenario] % [@provider, scenario_id]

    et_api_request(:get, url, HEADERS)
  end

  def update_scenario(scenario_id)
    url = ETM_URLS[:scenario] % [@provider, scenario_id]

    et_api_request(:put, url, @params, HEADERS)
  end

  def merit(scenario_id)
    url = ETM_URLS[:merit] % [@provider, scenario_id]

    et_api_request(:get, url, HEADERS)
  end

  def inputs(scenario_id)
    et_api_request(:get, ETM_URLS[:inputs] % [@provider, scenario_id], HEADERS)
  end

  def gquery(scenario_id)
    if response = update_scenario(scenario_id)
      gquery_key = @params[:gqueries].first
      response["gqueries"][gquery_key]
    else
      nil
    end
  end

  def create_scenario
    url = ETM_URLS[:scenarios] % [@provider]

    et_api_request(:post, url, @params, HEADERS)
  end

  private

    def et_api_request(method, *args)
      JSON.parse(RestClient.public_send(method, *args))
    end
end
