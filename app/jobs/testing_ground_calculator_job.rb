class TestingGroundCalculatorJob
  def initialize(testing_ground, strategies)
    @testing_ground = testing_ground
    @strategies = strategies || {}
  end

  def perform
    cache.write(@testing_ground.to_calculated_graph(@strategies))
  end

  def success(job)
    store_strategies
    @testing_ground.update_column(:job_finished_at, DateTime.now)
  end

  def error(job, exception)
    if %w(development test).include?(Rails.env)
      raise exception
    else
      Airbrake.notify(exception)
    end
  end

  private

  def store_strategies
    if @strategies.any?
      @testing_ground.selected_strategy.update_attributes(@strategies.permit(@strategies.keys))
    end
  end

  def cache
    @cache ||= NetworkCache::Cache.new(@testing_ground, @strategies)
  end
end
