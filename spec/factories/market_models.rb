include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :market_model do
    name "Market model"
    interactions [{'stakeholder_from'=>'stakeholder_1', 'stakeholder_to'=>'stakeholder_2', 'foundation'=>'kW_max', 'tariff'=>'0.5'}]
  end
end

