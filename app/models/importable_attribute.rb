class ImportableAttribute < ActiveRecord::Base
  belongs_to :technology, primary_key: 'technology_key'

  validates :name,
    presence: true,
    inclusion: { in: Import::TechnologyBuilder::ATTRIBUTES.keys }
end
