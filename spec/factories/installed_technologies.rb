FactoryGirl.define do
  factory :installed_base_load, class: InstalledTechnology do
    type 'base_load'
    units 1
    demand 8760
  end

  factory :installed_base_load_building, class: InstalledTechnology do
    type 'base_load_buildings'
    units 1
    demand 8760
  end

  factory :installed_pv, class: InstalledTechnology do
    units 1
    capacity(-2.0)
  end

  factory :installed_tv, class: InstalledTechnology do
    units 1
    capacity 1.0
  end

  factory :installed_battery, class: InstalledTechnology do
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
    units 1
    capacity Float::INFINITY

    after(:build) do |tech|
      allow(tech).to receive(:technology).and_return(
        build(:technology, behavior: 'siphon')
      )
    end
  end

  factory :installed_heat_pump, class: InstalledTechnology do
    units 1
    capacity Float::INFINITY

    after(:build) do |tech|
      allow(tech).to receive(:technology).and_return(
        build(:technology, behavior: 'buffer')
      )
    end
  end

  factory :installed_deferred, class: InstalledTechnology do
    units 1
    capacity Float::INFINITY

    after(:build) do |tech|
      allow(tech).to receive(:technology).and_return(
        build(:technology, behavior: 'deferrable')
      )
    end
  end

  factory :installed_optional, class: InstalledTechnology do
    units 1
    capacity Float::INFINITY

    after(:build) do |tech|
      allow(tech).to receive(:technology).and_return(
        build(:technology, behavior: 'optional')
      )
    end
  end

  factory :installed_space_heater_heat_exchanger, class: InstalledTechnology do
    type 'households_space_heater_district_heating_steam_hot_water'
    units 1
    capacity Float::INFINITY

    after(:build) do |tech|
      allow(tech).to receive(:technology).and_return(
        build(:technology, behavior: 'heat_consumer')
      )
    end
  end

  factory :installed_water_heater_heat_exchanger, class: InstalledTechnology do
    type 'households_water_heater_district_heating_steam_hot_water'
    units 1
    capacity Float::INFINITY

    after(:build) do |tech|
      allow(tech).to receive(:technology).and_return(
        build(:technology, behavior: 'heat_consumer')
      )
    end
  end

end
