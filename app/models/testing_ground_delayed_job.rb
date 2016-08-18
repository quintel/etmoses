class TestingGroundDelayedJob < ActiveRecord::Base
  belongs_to :testing_ground
  belongs_to :job, class_name: '::Delayed::Job', dependent: :destroy

  def self.for(job_type)
    find_by(job_type: job_type)
  end
end
