class Company < ApplicationRecord
  has_many :categories
  has_many :locations
  has_many :suppliers
  has_many :items
  has_many :users
  has_many :stock_movements
end
