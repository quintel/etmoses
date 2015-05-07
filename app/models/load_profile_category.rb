class LoadProfileCategory < ActiveRecord::Base
  has_many :load_profiles

  def self.hierarchic_order
    order("COALESCE(`parent_id`, `id`), `parent_id`, `id`")
  end

  def parent
    self.class.find(self.parent_id)
  end

  def children
    self.class.where(parent_id: self.id)
  end

  def parent_count(count = 0)
    if self.parent_id
      count += 1
      self.parent.parent_count(count)
    else
      count
    end
  end
end
