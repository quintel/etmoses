class MarketModel::Update
  def self.update(market_model, market_model_params)
    new(market_model, market_model_params).update
  end

  def initialize(market_model, market_model_params)
    @market_model = market_model
    @market_model_params = market_model_params
  end

  def update
    BusinessCase.where(testing_ground: testing_grounds).each(&:clear_job!)

    @market_model.update_attributes(@market_model_params)
  end

  private

  def testing_grounds
    TestingGround.where(market_model: @market_model)
  end
end
