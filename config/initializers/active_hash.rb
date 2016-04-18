Rails.application.config.to_prepare do
  DATA_SOURCES = {
    "connectors" => GasAssets::Connector,
    "pipes"      => GasAssets::Pipe
  }.freeze

  DATA_SOURCES.each_pair do |folder, static|
    static.data = Dir["#{ Rails.root }/db/static/#{ folder }/*.yml"].map do |path|
      file = File.open(path)

      YAML.load(file.read).update(type: File.basename(file, ".*"))
    end
  end
end
