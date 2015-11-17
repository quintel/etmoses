class SelectedStrategy < ActiveRecord::Base
  belongs_to :testing_ground

  def attributes
    super.except('id', 'testing_ground_id')
  end

  def self.strategy_type(strategies)
    strategies.symbolize_keys.except(:capping_fraction).values.any? ? 'feature' : 'basic'
  end
end
