class PermittedTechnology < ActiveRecord::Base
  belongs_to :load_profile
  validates :technology, presence: true, uniqueness: { scope: :load_profile_id }
end
