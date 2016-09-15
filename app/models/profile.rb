class Profile < ActiveRecord::Base
  include Privacy
  include CurveComponent.module

  belongs_to :user
end
