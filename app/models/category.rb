# frozen_string_literal: true

# Category
class Category < ApplicationRecord
  belongs_to :company
  has_many :items, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }

  # Ransackの検索可能な属性を定義
  def self.ransackable_attributes(_auth_object = nil)
    %w[id name description company_id created_at updated_at]
  end

  # Ransackの検索可能な関連を定義
  def self.ransackable_associations(_auth_object = nil)
    %w[company items]
  end
end
