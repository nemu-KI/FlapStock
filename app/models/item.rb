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
    %w[name sku stock_quantity unit description min_stock max_stock created_at updated_at]
  end

  # Ransackの検索可能な関連を定義
  def self.ransackable_associations(_auth_object = nil)
    %w[category location supplier]
  end

  private

  def max_stock_greater_than_min_stock
    return unless max_stock <= min_stock

    errors.add(:max_stock, 'は最小在庫より大きい値で入力してください')
  end
end
