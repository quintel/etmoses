class TestingGround < ActiveRecord::Base
  serialize :technologies, JSON
end
