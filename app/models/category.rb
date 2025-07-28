class Category < ApplicationRecord
  belongs_to :company
  has_many :items

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }
end
