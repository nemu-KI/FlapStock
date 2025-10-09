# frozen_string_literal: true

# ApplicationMailer
class ApplicationMailer < ActionMailer::Base
  default from: 'flapstockapp@gmail.com'
  layout 'mailer'
end
