include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :market_model_template do
    name "Market model template"
    public "true"
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

