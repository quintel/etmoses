class BusinessCase < ActiveRecord::Base
  belongs_to :testing_ground
  belongs_to :job, class: Delayed::Job

  serialize :financials, JSON

  def freeform
    if financials && freeform_row = financials.detect{|t| t['freeform'] }
      freeform_row
    else
      {'freeform' => [nil] * financials.size }
    end
  end

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
