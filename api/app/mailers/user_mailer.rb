# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to TaskFlow!')
  end

  def password_reset_email(user)
    @user = user
    mail(to: @user.email, subject: 'Password Reset Instructions')
  end
end
