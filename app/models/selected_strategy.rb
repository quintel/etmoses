class SelectedStrategy < ActiveRecord::Base
  belongs_to :testing_ground

  def attributes
    super.except('id', 'testing_ground_id')
  end
end
