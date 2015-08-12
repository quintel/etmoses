class BusinessCase < ActiveRecord::Base
  FREEFORM_ROW = { 'freeform' => [nil] * Stakeholder.all.size }

  belongs_to :testing_ground

  serialize :financials, JSON

  def financials=(financials)
    if(financials.is_a?(Array))
      super(financials)
    else
      super(JSON.parse(financials))
    end
  end
end
