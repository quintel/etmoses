class ImportableAttribute < ActiveRecord::Base
  belongs_to :technology

  validates :name,
    presence: true,
    inclusion: { in: Import::TechnologyBuilder::ATTRIBUTES.keys }
end
