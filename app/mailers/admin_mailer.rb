# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def account_creation(admin_id, password)
    @admin = Admin.find(admin_id)
    @password = password
    mail(to: @admin.email, subject: 'New account creation')
  end
end
