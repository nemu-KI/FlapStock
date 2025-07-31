class Company < ApplicationRecord
  has_many :categories
  has_many :locations
  has_many :suppliers
  has_many :items
  has_many :users
  has_many :stock_movements

  # Ransackの検索可能な属性を定義
  def self.ransackable_attributes(auth_object = nil)
    %w[id name email active created_at updated_at]
  end

  # Ransackの検索可能な関連を定義
  def self.ransackable_associations(auth_object = nil)
    %w[categories locations suppliers items users stock_movements]
  end
end
