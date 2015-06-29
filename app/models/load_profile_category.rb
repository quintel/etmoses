class LoadProfileCategory < ActiveRecord::Base
  has_many :load_profiles

  def parent
    self.class.find_by_id(self.parent_id)
  end

  def children
    self.class.where(parent_id: self.id)
  end
end
