class User < ActiveRecord::Base
  def activate!
    update_column(:activated, true)
  end
end
