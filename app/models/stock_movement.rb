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
  before_destroy :check_adjustment_deletion
  after_destroy :revert_item_stock

  # Ransack対応
  def self.ransackable_attributes(auth_object = nil)
    %w[id quantity reason note created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[item user company]
  end

  # カスタム検索メソッド
  def self.ransackable_scopes(auth_object = nil)
    %w[with_movement_category]
  end

  scope :with_movement_category, ->(category) {
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
    if outbound? && item.stock_quantity < quantity
      errors.add(:quantity, :insufficient_stock, current_stock: item.stock_quantity, unit: item.unit)
    end
  end

  def check_adjustment_deletion
    if movement_category == 'adjustment'
      errors.add(:base, :adjustment_deletion_not_allowed)
      throw(:abort)
    end
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
end
