class StockMovement < ApplicationRecord
  belongs_to :company
  belongs_to :user
  belongs_to :item

  enum movement_category: { inbound: 0, outbound: 1, adjustment: 2 }
end
