class AddInitialInvestmentTechnicalLifetimeAttributesToDb < ActiveRecord::Migration
  def change
    Technology.where("`key` != 'transport_car_using_electricity'").map do |technology|
      technology.importable_attributes.create(name: 'initial_investment')
      technology.importable_attributes.create(name: 'technical_lifetime')
    end
  end
end
