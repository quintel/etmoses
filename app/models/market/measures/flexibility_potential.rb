module Market::Measures
  # The average flexibility of the measurable throughout the year.
  module FlexibilityPotential
    def self.call(node, variants)
      flexes = Flexibility.new.call(node, variants)
      flexes.sum / flexes.length.to_f
    end

    def self.irregular?
      true
    end
  end
end
