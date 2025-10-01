# frozen_string_literal: true

# ApplicationMailer
class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@flapstock.com'
  layout 'mailer'
end
