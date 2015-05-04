class RegistrationForm
  include ActiveModel::Model

  attr_accessor :email, :password

  validates_presence_of :email, :password

  validates_confirmation_of :password

  validates_email_format_of :email

  validate :email_uniqueness

  def submit
    if self.valid?
      user = User.create!(attributes)
      RegistrationMailer.new_registration(user).deliver!
      true
    else
      false
    end
  end

  private

    def attributes
      { email: email,
        password: password }
    end

    def email_uniqueness
      if User.where(email: self.email).any?
        self.errors.add(:email, "is already taken")
      end
    end
end
