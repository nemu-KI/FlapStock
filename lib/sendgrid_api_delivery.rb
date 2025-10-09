# frozen_string_literal: true

require 'sendgrid-ruby'

# SendGrid Web API を使用したメール配信クラス
class SendgridApiDelivery
  include SendGrid

  attr_accessor :settings

  def initialize(settings)
    @settings = settings
  end

  def deliver!(mail)
    api = SendGrid::API.new(api_key: settings[:api_key])
    sg_mail = build_sendgrid_mail(mail)
    send_mail(api, sg_mail)
  rescue StandardError => e
    handle_error(e)
  end

  private

  def build_sendgrid_mail(mail)
    from = Email.new(email: mail.from.first)
    subject = mail.subject
    to = Email.new(email: mail.to.first)

    sg_mail = if mail.multipart?
                build_multipart_mail(mail, from, subject, to)
              else
                build_simple_mail(mail, from, subject, to)
              end

    add_additional_recipients(sg_mail, mail)
    add_reply_to(sg_mail, mail)

    sg_mail
  end

  def build_multipart_mail(mail, from, subject, to)
    html_part = mail.html_part&.body&.decoded || ''
    text_part = mail.text_part&.body&.decoded || ''

    content_html = Content.new(type: 'text/html', value: html_part) if html_part.present?
    content_text = Content.new(type: 'text/plain', value: text_part) if text_part.present?

    sg_mail = Mail.new(from, subject, to, content_html)
    sg_mail.add_content(content_text) if content_text

    sg_mail
  end

  def build_simple_mail(mail, from, subject, to)
    content = Content.new(
      type: mail.content_type.include?('html') ? 'text/html' : 'text/plain',
      value: mail.body.decoded
    )
    Mail.new(from, subject, to, content)
  end

  def add_additional_recipients(sg_mail, mail)
    mail.to.drop(1).each do |recipient|
      personalization = Personalization.new
      personalization.add_to(Email.new(email: recipient))
      sg_mail.add_personalization(personalization)
    end
  end

  def add_reply_to(sg_mail, mail)
    return unless mail.reply_to.present?

    reply_to = ReplyTo.new(email: mail.reply_to.first)
    sg_mail.reply_to = reply_to
  end

  def send_mail(api, sg_mail)
    response = api.client.mail._('send').post(request_body: sg_mail.to_json)

    unless response.status_code.to_s.start_with?('2')
      raise "SendGrid API Error: #{response.status_code} - #{response.body}"
    end

    response
  end

  def handle_error(error)
    Rails.logger.error "SendGrid API delivery failed: #{error.message}"
    Rails.logger.error error.backtrace.join("\n")
    raise
  end
end
