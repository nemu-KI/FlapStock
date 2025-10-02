# frozen_string_literal: true

# Item
class Item < ApplicationRecord
  belongs_to :company
  belongs_to :category
  belongs_to :location
  belongs_to :supplier
  has_many :stock_movements, dependent: :destroy

  has_one_attached :image

  validates :name, presence: true
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :min_stock, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :max_stock, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :max_stock_greater_than_min_stock, if: -> { min_stock.present? && max_stock.present? }

  # Ransackの検索可能な属性を定義
  def self.ransackable_attributes(_auth_object = nil)
    %w[name sku stock_quantity unit description min_stock max_stock category_id location_id supplier_id created_at
       updated_at]
  end

  # Ransackの検索可能な関連を定義
  def self.ransackable_associations(_auth_object = nil)
    %w[category location supplier]
  end

  # 在庫アラート関連のスコープ
  scope :with_stock_alerts, -> { where.not(min_stock: nil).or(where.not(max_stock: nil)) }
  scope :low_stock, -> { where('min_stock IS NOT NULL AND stock_quantity <= min_stock') }
  scope :overstock, -> { where('max_stock IS NOT NULL AND stock_quantity > max_stock') }

  # 在庫アラート判定メソッド
  def stock_alert_status
    return 'normal' if min_stock.nil? && max_stock.nil?

    if min_stock.present? && stock_quantity <= min_stock
      'low_stock'
    elsif max_stock.present? && stock_quantity > max_stock
      'overstock'
    else
      'normal'
    end
  end

  def needs_alert?
    stock_alert_status != 'normal'
  end

  def alert_message
    case stock_alert_status
    when 'low_stock'
      "在庫不足（現在: #{stock_quantity}#{unit}、最小在庫: #{min_stock}#{unit}）"
    when 'overstock'
      "在庫過剰（現在: #{stock_quantity}#{unit}、最大在庫: #{max_stock}#{unit}）"
    end
  end

  private

  def max_stock_greater_than_min_stock
    return unless max_stock <= min_stock

    errors.add(:max_stock, 'は最小在庫より大きい値で入力してください')
  end
end
