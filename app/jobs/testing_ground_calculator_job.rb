class TestingGroundCalculatorJob
  def initialize(testing_ground, params)
    @testing_ground = testing_ground
    @strategies = params[:strategies]
  end

  def perform
    @testing_ground.to_json(@strategies)
  end

  def before(job)
    testing_ground.update_attribute(:job_id, job.id)
  end

  def success(job)
    testing_ground.update_attribute(:job_finished_at, DateTime.now)
  end

  def error(job, exception)
    Airbrake.notify(exception)
  end
end
