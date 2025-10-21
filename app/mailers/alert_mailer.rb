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

  # バッチ在庫アラート通知メール
  def batch_stock_alert(company, alert_items, recipients)
    @company = company
    @alert_items = alert_items
    @low_stock_items = alert_items.select { |item| item.stock_alert_status == 'low_stock' }
    @overstock_items = alert_items.select { |item| item.stock_alert_status == 'overstock' }

    mail(
      to: recipients.map(&:email),
      subject: "[#{@company.name}] 在庫アラート一覧 (#{alert_items.count}件)",
      reply_to: 'flapstockapp@gmail.com'
    )
  end

  # 通知対象ユーザーを取得
  def self.notification_recipients(company)
    # 会社の設定で通知が無効の場合は空配列を返す
    return [] unless company.email_notifications_enabled?

    # 通知対象が設定されている場合はそのユーザーを返す
    if company.notification_recipients_list.any?
      company.users.where(id: company.notification_recipients_list)
    else
      # デフォルト: 管理者・マネージャー
      company.users.where(role: %w[admin manager])
    end
  end
end
