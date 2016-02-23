class UpdateIncludedInConcurrencyForAllLoadProfiles < ActiveRecord::Migration
  def change
    LoadProfile.update_all(included_in_concurrency: true)
  end
end
