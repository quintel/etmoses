module Privacy
  extend ActiveSupport::Concern

  def private?
    ! public?
  end

  included do
    scope(:visible_to, lambda do |user|
      if user.nil?
        where(public: true)
      else
        where('`user_id` = ? OR `public` = ?', user.id, true)
      end
    end)
  end
end
