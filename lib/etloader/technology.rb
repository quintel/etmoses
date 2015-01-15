module ETLoader
  class Technology
    include Virtus.model

    attribute :name,       String
    attribute :efficiency, Float
    attribute :capacity,   Float
    attribute :demand,     Float
  end # Technology
end # ETLoader
