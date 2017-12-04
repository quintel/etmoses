class AssetListSerializer
  def self.dump(array)
    array.to_yaml
  end

  def self.load(array)
    array.nil? ? [] : YAML.load(array).map(&:symbolize_keys)
  end
end
