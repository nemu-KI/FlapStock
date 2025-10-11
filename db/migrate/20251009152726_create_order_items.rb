class CreateOrderItems < ActiveRecord::Migration[7.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.decimal :unit_price, precision: 10, scale: 2
      t.date :expected_delivery_date
      t.text :notes

      t.timestamps
    end

    add_index :order_items, [:order_id, :item_id]
  end
end
