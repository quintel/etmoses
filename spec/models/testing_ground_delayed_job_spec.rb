require 'rails_helper'

RSpec.describe TestingGroundDelayedJob do
  it "destroys the delayed job that accompanies the testing ground delayed job" do
    delayed_job = Delayed::Job.create!(handler: '')
    testing_ground_delayed_job = TestingGroundDelayedJob.create!(job: delayed_job)
    testing_ground_delayed_job.destroy!

    expect(Delayed::Job.count).to eq(0)
  end
end
