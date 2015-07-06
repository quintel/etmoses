module Market
  # The simplest possible tariff. Given a price, multiplies the number of
  # measured units by the price.
  class Tariff
    def initialize(price)
      @price = price.to_f
    end

    def price_of(units)
      @price * units
    end
  end # Tariff
end # Market
