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

  private

  def max_stock_greater_than_min_stock
    if max_stock <= min_stock
      errors.add(:max_stock, "は最小在庫より大きい値で入力してください")
    end
  end
end
