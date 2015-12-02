class TestingGround::Calculator
  def initialize(testing_ground, strategies)
    @testing_ground = testing_ground
    @strategies     = strategies || {}
  end

  def calculate
    if cache.present?
      existing_job.destroy if existing_job

      base.merge(
        graph: GraphToTree.convert(network(:electricity)),
        gas:   GraphToTree.convert(network(:gas))
      )
    else
      calculate_load_in_background

      @strategies.merge(pending: existing_job.finished_at.blank?)
    end
  end

  def network(carrier)
    fetch_networks.detect { |net| net.carrier == carrier }
  end

  private

  def calculate_load_in_background
    return if existing_job

    job = @testing_ground.testing_ground_delayed_jobs.create!(job_type: job_type)
    job.update_column(:job_id, Delayed::Job.enqueue(task))
  end

  def existing_job
    @testing_ground.testing_ground_delayed_jobs.for(job_type)
  end

  def task
    TestingGroundCalculatorJob.new(@testing_ground, @strategies)
  end

  def fetch_networks
    @networks ||= cache.fetch
  end

  def cache
    @cache ||= NetworkCache::Cache.new(@testing_ground, @strategies)
  end

  def job_type
    SelectedStrategy.strategy_type(@strategies)
  end

  def base
    { technologies: @testing_ground.technology_profile.as_json }
  end
end
