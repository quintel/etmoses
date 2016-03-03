class TestingGroundCalculatorJob
  def initialize(testing_ground, options)
    @testing_ground = testing_ground
    @options        = options
    @strategies     = options.fetch(:strategies)
  end

  def perform
    cache.write(network_calculation)
  end

  def success(job)
    if job = @testing_ground.testing_ground_delayed_jobs.for(job_type)
      @testing_ground.update_attribute(:range, @options[:range])

      TestingGround::StrategyUpdater.new(@testing_ground, strategy_params).update

      job.destroy
    end
  end

  def error(job, exception)
    if %w(development test).include?(Rails.env)
      raise exception
    else
      Airbrake.notify(exception)
    end
  end

  private

  def strategy_params
    ActionController::Parameters.new(strategies: @strategies.symbolize_keys)
  end

  def job_type
    SelectedStrategy.strategy_type(@strategies)
  end

  def network_calculation
    @testing_ground.to_calculated_graphs(@options)
  end

  def cache
    NetworkCache::Cache.new(@testing_ground, @options)
  end
end
