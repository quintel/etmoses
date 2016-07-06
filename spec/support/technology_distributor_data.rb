module TechnologyDistributorData
  def self.load_file(file)
    YAML.load(File.read("#{Rails.root}/spec/fixtures/data/technology_distributions/#{ file }.yml"))
  end

  def self.load_concurrency_file(file)
    YAML.load(File.read("#{Rails.root}/spec/fixtures/data/concurrency/#{ file }.yml"))
  end

  def basic_technologies(units = '2.0')
    [{ "name"=>"Residential PV panel",
      "type"=>"households_solar_pv_solar_radiation",
      "capacity"=>"-1.5",
      "units"=>units }]
  end
end
