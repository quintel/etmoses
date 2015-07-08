class FinancialProfile < Profile
  belongs_to :user

  has_attached_file :curve
end
