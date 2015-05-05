FactoryGirl.define do
  factory :installed_pv, class: InstalledTechnology do
    name 'PV Panel'
    units 1
    capacity -2.0
  end

  factory :installed_tv, class: InstalledTechnology do
    name 'Television'
    units 1
    capacity 1.0
  end

  factory :installed_battery, class: InstalledTechnology do
    name 'Battery'
    units 1
    storage 1.0

    after(:build) do |tech|
      allow(tech).to receive(:technology).and_return(
        build(:technology, behavior: 'storage')
      )
    end
  end
end
