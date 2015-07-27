class BusinessCase < ActiveRecord::Base
  belongs_to :testing_ground

  serialize :financials
end
