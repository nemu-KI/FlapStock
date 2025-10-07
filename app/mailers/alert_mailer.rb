# frozen_string_literal: true

# 在庫アラート通知用メーラー
class AlertMailer < ApplicationMailer
  default from: 'flapstockapp@gmail.com'

  # 在庫アラート通知メール
  def stock_alert(item, alert_type, recipients)
    @item = item
    @company = item.company
    @alert_type = alert_type
    @alert_message = item.alert_message
    @current_stock = item.stock_quantity
    @threshold = alert_type == 'low_stock' ? item.min_stock : item.max_stock
    @unit = item.unit
    @location = item.location.name
    @category = item.category.name
    @supplier = item.supplier.name

    mail(
      to: recipients.map(&:email),
      subject: "[#{@company.name}] 在庫アラート: #{@item.name}",
      reply_to: 'flapstockapp@gmail.com'
    )
  end

  # 通知対象ユーザーを取得
  def self.notification_recipients(company)
    company.users.where(role: %w[admin manager])
  end
end
