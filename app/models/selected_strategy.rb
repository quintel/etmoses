class SelectedStrategy < ActiveRecord::Base
  belongs_to :testing_ground

  def as_json(*)
    attributes.except('id', 'testing_ground_id')
  end
end
