class TestingGround::Calculator
  def initialize(testing_ground, options)
    @testing_ground = testing_ground
    @options        = options || {}
  end

  def calculate
    if cache.present?
      @testing_ground.update_attribute(:job_id, nil)

      base.merge(graph: GraphToTree.convert(cache.fetch))
    else
      calculate_load_in_background

      @options.merge(pending: @testing_ground.job_finished_at.blank?)
    end
  end

  private

  def calculate_load_in_background
    unless @testing_ground.job_id.present?
      @testing_ground.update_attributes(job: Delayed::Job.enqueue(task), job_finished_at: nil)
    end
  end

  def task
    TestingGroundCalculatorJob.new(@testing_ground, @options)
  end

  def cache
    @cache ||= NetworkCache::Cache.new(@testing_ground, @options)
  end

  def base
    { technologies: @testing_ground.technology_profile.as_json }
  end
end
