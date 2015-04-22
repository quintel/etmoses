class RegistrationForm
  include ActiveModel::Model

  attr_accessor :email, :password

  validates_presence_of :email, :password

  validates_email_format_of :email

  def submit
    if self.valid?
      user = Monban::Services::SignUp.new(attributes).perform
      RegistrationMailer.new_registration(user).deliver!
      true
    else
      false
    end
  end

  private

    def attributes
      { email: email,
        password: password
      }
    end
end
