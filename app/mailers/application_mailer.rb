# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  # TODO: BY Saadat: Configure it to correct email later
  default from: 'from@example.com'
  layout 'mailer'
end
