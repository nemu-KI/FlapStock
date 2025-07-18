class CreateItems < ActiveRecord::Migration[7.1]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.integer :stock_quantity, null: false, default: 0
      t.string :unit, null: false

      t.references :category, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true

      t.timestamps
    end
  end
end
