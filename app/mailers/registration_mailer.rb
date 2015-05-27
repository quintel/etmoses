class RegistrationMailer < ActionMailer::Base
  default from: "no-reply@quintel.com"

  def new_registration(user)
    @user = user
    mail(to: 'chael.kruip@quintel.com',
         subject: "New registration ETMoses")
  end
end
