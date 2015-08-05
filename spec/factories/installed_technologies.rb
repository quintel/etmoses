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
    volume 1.0
    capacity Float::INFINITY

    after(:build) do |tech|
      allow(tech).to receive(:technology).and_return(
        build(:technology, behavior: 'storage')
      )
    end
  end

  factory :installed_ev, class: InstalledTechnology do
    name 'Electric Vehicle'
    units 1
    volume 1.0
    capacity Float::INFINITY

    after(:build) do |tech|
      allow(tech).to receive(:technology).and_return(
        build(:technology, behavior: 'electric_vehicle')
      )
    end
  end

  factory :installed_p2h, class: InstalledTechnology do
    name 'Power-to-heat'
    units 1
    volume 1.0
    capacity Float::INFINITY

    after(:build) do |tech|
      allow(tech).to receive(:technology).and_return(
        build(:technology, behavior: 'optional_buffer')
      )
    end
  end

  factory :installed_p2g, class: InstalledTechnology do
    name 'Power-to-gas'
    units 1
    capacity Float::INFINITY

    after(:build) do |tech|
      allow(tech).to receive(:technology).and_return(
        build(:technology, behavior: 'siphon')
      )
    end
  end

  factory :installed_heat_pump, class: InstalledTechnology do
    name 'Heat pump'
    units 1
    capacity Float::INFINITY

    after(:build) do |tech|
      allow(tech).to receive(:technology).and_return(
        build(:technology, behavior: 'buffer')
      )
    end
  end

  factory :installed_deferred, class: InstalledTechnology do
    name 'Heat pump'
    units 1
    capacity Float::INFINITY

    after(:build) do |tech|
      allow(tech).to receive(:technology).and_return(
        build(:technology, behavior: 'deferrable')
      )
    end
  end

  factory :installed_optional, class: InstalledTechnology do
    name 'Optional'
    units 1
    capacity Float::INFINITY

    after(:build) do |tech|
      allow(tech).to receive(:technology).and_return(
        build(:technology, behavior: 'optional')
      )
    end
  end
end
