module Strategies
  def self.all
    [
      { name: "no_storage",         enabled: true },
      { name: "storage_strategy_1", enabled: true },
      { name: "storage_strategy_2", enabled: false }
    ]
  end
end
