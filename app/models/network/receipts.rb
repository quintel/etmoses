module Network
  class Receipts
    attr_reader :production, :mandatory, :conditional

    def initialize
      @production  = DefaultArray.new { |_| 0.0 }
      @mandatory   = DefaultArray.new { |_| 0.0 }
      @conditional = DefaultArray.new { |_| 0.0 }
    end
  end # Receipts
end
