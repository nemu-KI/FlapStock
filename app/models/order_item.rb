# frozen_string_literal: true

# 発注明細モデル
class OrderItem < ApplicationRecord
  # アソシエーション
  belongs_to :order
  belongs_to :item

  # バリデーション
  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # 小計を計算
  def subtotal
    return nil unless unit_price.present?

    quantity * unit_price
  end
end
