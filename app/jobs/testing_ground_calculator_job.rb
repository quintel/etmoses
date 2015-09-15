class TestingGroundCalculatorJob
  def initialize(testing_ground, strategies)
    @testing_ground = testing_ground
    @strategies = strategies || {}
  end

  def perform
    @testing_ground.perform_calculation(@strategies)
  end

  def before(job)
    @testing_ground.update_attribute(:job_id, job.id)
  end

  def success(job)
    @testing_ground.update_attribute(:job_finished_at, DateTime.now)
  end

  def error(job, exception)
    if %w(test development).include?(Rails.env)
      puts exception
    else
      Airbrake.notify(exception)
    end
  end
end
