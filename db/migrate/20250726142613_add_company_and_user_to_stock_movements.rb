class AddCompanyAndUserToStockMovements < ActiveRecord::Migration[7.1]
  def change
    add_reference :stock_movements, :company, null: false, foreign_key: true
    add_reference :stock_movements, :user, null: false, foreign_key: true
  end
end
