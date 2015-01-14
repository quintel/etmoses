module ETLoader
  class Technology
    include Virtus.model

    attribute :name,       String
    attribute :efficiency, Float
    attribute :capacity,   Float
  end # Technology
end # ETLoader
