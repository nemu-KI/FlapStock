# frozen_string_literal: true

# UserMailer
class UserMailer < ApplicationMailer
  default from: 'flapstockapp@gmail.com'

  def password_reset(user, new_password)
    @user = user
    @new_password = new_password
    @company = user.company

    mail(
      to: @user.email,
      subject: "[#{@company.name}] パスワードがリセットされました",
      reply_to: 'flapstockapp@gmail.com'
    )
  end
end
