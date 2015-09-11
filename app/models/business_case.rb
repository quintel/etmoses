class BusinessCase < ActiveRecord::Base
  FREEFORM_ROW = { 'freeform' => [nil] * Stakeholder.all.size }

  belongs_to :testing_ground
  belongs_to :job, class: Delayed::Job

  serialize :financials, JSON

  def financials=(financials)
    if(financials.is_a?(Array))
      super(financials)
    else
      super(JSON.parse(financials))
    end
  end

  def clear_job!
    update_attributes(job_finished_at: nil, job_id: nil)
  end
end
