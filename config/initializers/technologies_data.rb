Rails.application.config.to_prepare do
  Technology.data = Dir["#{ Rails.root }/config/technologies/**/*.yml"].map do |technology|
    key = File.basename(technology, '.yml')

    YAML.load(File.read(technology)).merge(key: key)
  end
end
