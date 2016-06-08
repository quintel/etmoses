module Network
  module Builders
    def self.for(carrier)
      case carrier
        when :gas         then Gas
        when :electricity then Electricity
        when :heat        then Heat
        else              fail "Unknown carrier: #{ carrier.inspect }"
      end
    end
  end # Builders
end
