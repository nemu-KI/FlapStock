# frozen_string_literal: true

# アラート送信のスケジューリングを管理するサービス
class AlertScheduler
  def initialize(company)
    @company = company
  end

  # アラートを送信すべきかどうかを判定
  def should_send_alert?
    return false unless @company.email_notifications_enabled?
    return true if @company.notification_frequency == 'immediate'
    return false if @company.notification_frequency.blank?

    # 日次・週次の場合は時間をチェック
    case @company.notification_frequency
    when 'daily'
      should_send_daily_alert?
    when 'weekly'
      should_send_weekly_alert?
    else
      false
    end
  end

  # 即時送信のアラートをキューに追加
  def queue_immediate_alert(item, alert_type)
    return unless @company.notification_frequency == 'immediate'

    recipients = AlertMailer.notification_recipients(@company)
    return if recipients.empty?

    AlertMailer.stock_alert(item, alert_type, recipients).deliver_now
  end

  # 日次・週次のアラートをキューに追加（バッチ処理用）
  def queue_batch_alerts
    return unless should_send_alert?
    return if already_sent_today?

    alert_items = find_alert_items
    return if alert_items.empty?

    recipients = find_recipients
    return if recipients.empty?

    send_batch_alert(alert_items, recipients)
  end

  private

  def already_sent_today?
    return false unless @company.last_batch_alert_sent.present?

    last_sent = @company.last_batch_alert_sent.in_time_zone(@company.timezone || 'Asia/Tokyo')
    current_time = Time.current.in_time_zone(@company.timezone || 'Asia/Tokyo')

    # 同じ日で、かつ1時間以内に送信済みの場合は重複とみなす
    same_date = last_sent.to_date == current_time.to_date
    within_hour = (current_time - last_sent) < 1.hour
    same_date && within_hour

  end

  def should_send_daily_alert?
    return false unless @company.notification_time.present?

    current_time = Time.current.in_time_zone(@company.timezone || 'Asia/Tokyo')
    target_time = Time.zone.parse("#{current_time.to_date} #{@company.notification_time}")

    time_diff = (current_time - target_time).abs
    time_diff <= 5.minutes

  end

  def should_send_weekly_alert?
    return false unless @company.notification_time.present?
    return false unless Date.current.wday == 1 # 月曜日のみ

    should_send_daily_alert?
  end

  def find_alert_items
    @company.items.with_stock_alerts.select(&:needs_alert?)
  end

  def find_recipients
    AlertMailer.notification_recipients(@company)

  end

  def send_batch_alert(alert_items, recipients)
    AlertMailer.batch_stock_alert(@company, alert_items, recipients).deliver_now
    # 送信日時を記録
    @company.update_column(:last_batch_alert_sent, Time.current)
  end
end
