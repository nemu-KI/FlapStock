# frozen_string_literal: true

# StockMovement
class StockMovement < ApplicationRecord
  belongs_to :company
  belongs_to :user
  belongs_to :item

  enum movement_category: { inbound: 0, outbound: 1, adjustment: 2 }

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :movement_category, presence: true
  validates :reason, presence: true, length: { maximum: 100 }
  validates :note, length: { maximum: 500 }
  validate :check_stock_availability, if: :outbound?

  after_create :update_item_stock
  after_create :check_and_send_alert
  before_destroy :check_adjustment_deletion
  after_destroy :revert_item_stock

  # Ransack対応
  def self.ransackable_attributes(_auth_object = nil)
    %w[id quantity reason note created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[item user company]
  end

  # カスタム検索メソッド
  def self.ransackable_scopes(_auth_object = nil)
    %w[with_movement_category]
  end

  scope :with_movement_category, lambda { |category|
    if category.present?
      where(movement_category: category)
    else
      all
    end
  }

  # 日本語化メソッド
  def movement_category_i18n
    I18n.t("activerecord.enums.stock_movement.movement_category.#{movement_category}")
  end

  private

  def check_stock_availability
    return unless outbound? && item.stock_quantity < quantity

    errors.add(:quantity, :insufficient_stock, current_stock: item.stock_quantity, unit: item.unit)
  end

  def check_adjustment_deletion
    return unless movement_category == 'adjustment'

    errors.add(:base, :adjustment_deletion_not_allowed)
    throw(:abort)
  end

  def update_item_stock
    case movement_category
    when 'inbound'
      item.increment!(:stock_quantity, quantity)
    when 'outbound'
      item.decrement!(:stock_quantity, quantity)
    when 'adjustment'
      # 調整の場合は直接数量を設定
      item.update!(stock_quantity: quantity)
    end
  end

  def revert_item_stock
    case movement_category
    when 'inbound'
      item.decrement!(:stock_quantity, quantity)
    when 'outbound'
      item.increment!(:stock_quantity, quantity)
    when 'adjustment'
      # 調整レコードは削除されないため、ここには到達しない
    end
  end

  def check_and_send_alert
    return unless item.needs_alert?

    # 通知対象ユーザーを取得
    recipients = AlertMailer.notification_recipients(company)
    return if recipients.empty?

    # 重複送信防止: 最近同じアラートが送信されていないかチェック
    return if recent_alert_sent?

    # アラート通知メールを送信
    AlertMailer.stock_alert(item, item.stock_alert_status, recipients).deliver_now
  end

  def recent_alert_sent?
    # 過去30分以内に同じ物品のアラートメールが送信されているかチェック
    # アラート状態が変化した場合は送信する
    recent_movements = company.stock_movements
                              .joins(:item)
                              .where(items: { id: item.id })
                              .where('stock_movements.created_at > ?', 30.minutes.ago)
                              .where.not(id: id)

    # 最近の入出庫でアラートが発生していた場合のみ重複送信を防ぐ
    recent_movements.any? do |movement|
      movement.item.needs_alert? && movement.item.stock_alert_status == item.stock_alert_status
    end
  end
end
