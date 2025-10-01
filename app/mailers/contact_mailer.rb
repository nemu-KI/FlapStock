# frozen_string_literal: true

# お問い合わせメーラー
class ContactMailer < ApplicationMailer
  def notify_admin(contact)
    @contact = contact
    mail(
      to: 'flapstockapp@gmail.com',
      subject: "[FlapStock] お問い合わせ: #{@contact.category_label} - #{@contact.subject}"
    )
  end
end
