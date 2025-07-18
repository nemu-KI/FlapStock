class CreateStockMovements < ActiveRecord::Migration[7.1]
  def change
    create_table :stock_movements do |t|
      t.references :item, null: false, foreign_key: true
      t.integer :movement_category, null: false
      t.integer :quantity, null: false
      t.string :reason
      t.text :note

      t.timestamps
    end
  end
end
