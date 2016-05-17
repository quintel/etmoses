class Import
  class DefaultTechnologyBuilder < Builder
    include Filters

    def build(response)
      response.reject(&method(:hybrid?)).reject(&method(:electric_vehicle?))
    end
  end
end
