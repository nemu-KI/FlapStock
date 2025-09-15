class Company < ApplicationRecord
  has_many :categories, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :suppliers, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :stock_movements, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true

  # Ransackの検索可能な属性を定義
  def self.ransackable_attributes(auth_object = nil)
    %w[id name email active created_at updated_at]
  end

  # Ransackの検索可能な関連を定義
  def self.ransackable_associations(auth_object = nil)
    %w[categories locations suppliers items users stock_movements]
  end
end
