class Import
  StorageVolumeAttribute =
    Attribute.new('volume', 'storage.volume') do |value, *|
      value * 1000 # MWh to kWh
    end
end
