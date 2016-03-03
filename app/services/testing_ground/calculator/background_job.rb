class TestingGround::Calculator
  module BackgroundJob
    def calculate_background_job
      return if existing_job && existing_job.job

      job = @testing_ground.testing_ground_delayed_jobs.create!(job_type: job_type)
      job.update_attribute(:job, Delayed::Job.enqueue(task))
    end

    def destroy_background_job
      existing_job.destroy if existing_job
    end

    private

    def task
      TestingGroundCalculatorJob.new(@testing_ground, calculation_options)
    end

    def job_type
      SelectedStrategy.strategy_type(strategies)
    end

    def existing_job
      @testing_ground.testing_ground_delayed_jobs.for(job_type)
    end
  end
end
