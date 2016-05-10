Rails.application.config.to_prepare do
  unless defined?(DATA_SOURCES)
    DATA_SOURCES = {
      "connectors" => GasAssets::Connector,
      "pipes"      => GasAssets::Pipe,
    }.freeze
  end

  data_path = Rails.root.join(Settings.static_data_path.to_s)

  # Sanity check.
  if Settings.static_data_path.blank? || ! data_path.directory?
    fail "Incorrect `static_data_path' setting; either no value is set in " \
         "config/setting.yml or config/settings/#{ Rails.env }.yml, or the " \
         "directory does not exist: #{ Settings.static_data_path.inspect }"
  end

  DATA_SOURCES.each_pair do |folder, static|
    static.data = Dir[data_path.join("#{ folder }/**/*.yml")].map do |path|
      pressure_levels = GasAssets::Base::PRESSURE_LEVELS
      pressure_level  = path.scan(
        Regexp.new(pressure_levels.keys.join("|"))).first

      YAML.load_file(path).update(
        pressure_level: pressure_levels[pressure_level],
        type: File.basename(path, '.*')
      )
    end
  end

  # Technology data
  Technology.data = Dir[data_path.join("technologies/*.yml")].map do |path|
    Technology.defaults
      .merge(YAML.load_file(path))
      .merge(key: File.basename(path, '.yml'))
  end
end
