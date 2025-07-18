class Item < ApplicationRecord
  belongs_to :category
  belongs_to :location
  belongs_to :supplier
  has_many :stock_movements
end
