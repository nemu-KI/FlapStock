class Supplier < ApplicationRecord
  belongs_to :company
  has_many :items

  validates :name, presence: true, length: { maximum: 100 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone, length: { maximum: 20 }
  validates :contact_person, length: { maximum: 100 }
  validates :address, length: { maximum: 200 }
  validates :note, length: { maximum: 1000 }

  # Ransackの検索可能な属性を定義
  def self.ransackable_attributes(auth_object = nil)
    %w[id name email phone contact_person address note company_id created_at updated_at]
  end

  # Ransackの検索可能な関連を定義
  def self.ransackable_associations(auth_object = nil)
    %w[company items]
  end
end
