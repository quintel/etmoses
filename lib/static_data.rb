# Loads static technology and gas asset data.
# See lib/initializers/active_hash.rb
module StaticData
  DATA_SOURCES ||= {
    "gas_assets/connectors"  => GasAssets::Connector,
    "gas_assets/compressors" => GasAssets::Compressor,
    "gas_assets/pipes"       => GasAssets::Pipe,
    "heat_assets/primary"    => HeatAssets::Pipe,
    "heat_assets/secondary"  => HeatAssets::Location,
    "technologies"           => Technology,
    "chart_settings"         => ChartSetting
  }.freeze

  module_function

  def load_data!
    # Sanity check.
    if Settings.static_data_path.blank? || ! path.directory?
      fail "Incorrect `static_data_path' setting; either no value is set in " \
           "config/setting.yml or config/settings/#{ Rails.env }.yml, or the " \
           "directory does not exist: #{ Settings.static_data_path.inspect }"
    end

    grouped_assets.each do |subgroup, files|
      DATA_SOURCES[subgroup].data = files.map do |path|
        fetch_data(subgroup, path)
      end
    end
  end

  def fetch_data(subgroup, path)
    case subgroup
    when 'technologies'
      Technology.defaults
        .merge(YAML.load_file(path))
        .merge(key: File.basename(path, '.yml'))
    else
      YAML.load_file(path).update(type: File.basename(path, '.yml'))
    end
  end

  def path
    Rails.root.join(Settings.static_data_path.to_s)
  end

  def grouped_assets
    Dir[path.join("**/*.yml")].group_by do |file|
      keys = DATA_SOURCES.keys.join("|")

      file.sub(Regexp.new("#{ path.to_s }\/(#{ keys }).+\.yml"), '\1')
    end
  end
end
