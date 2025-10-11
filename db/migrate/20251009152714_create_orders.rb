class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :company, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, default: 'pending', null: false
      t.date :order_date
      t.date :expected_delivery_date
      t.text :notes

      t.timestamps
    end

    add_index :orders, [:company_id, :status]
    add_index :orders, [:company_id, :order_date]
  end
end
