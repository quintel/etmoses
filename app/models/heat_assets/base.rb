module HeatAssets
  class Base < ActiveHash::Base
    # Public: Retrieves the record with the matching +type+
    def self.by_type(type)
      where(type: type).first
    end
  end
end
