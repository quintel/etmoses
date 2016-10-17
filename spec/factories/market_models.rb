include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :market_model do
    market_model_template
    interactions [{
      "stakeholder_from"=>"customer",
      "stakeholder_to"=>"customer",
      "foundation"=>"connections",
      "applied_stakeholder"=>"customer",
      "tariff_type"=>"fixed",
      "tariff"=>5.2
    }]
  end
end

