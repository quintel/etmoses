class UsersForm
  include ActiveModel::Model

  attr_accessor :email, :password, :user, :name

  validates_presence_of :email

  validates_confirmation_of :password, if: -> {  password.present? }

  validates_email_format_of :email

  validate :email_uniqueness

  def submit
    if self.valid?
      @user.update_attributes(attributes)
      true
    else
      false
    end
  end

  private

  def attributes
    { name: name,
      email: email,
      password: password }
  end

  def email_uniqueness
    if (@user.email != email && User.where(email: self.email).any?)
      self.errors.add(:email, "is already taken")
    end
  end
end
