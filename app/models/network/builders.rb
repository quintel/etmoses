module Network
  module Builders
    def self.for(carrier)
      case carrier
        when :gas         then Gas
        when :electricity then Electricity
        else              fail "Unknown carrier: #{ carrier.inspect }"
      end
    end
  end # Builders
end
