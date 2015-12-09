class Composite < ActiveRecord::Base
  belongs_to :technology
  belongs_to :composite, class: Technology
end
