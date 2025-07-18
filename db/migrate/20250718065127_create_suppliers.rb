class CreateSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name, null: false
      t.string :email
      t.string :phone, limit: 20
      t.string :address
      t.string :contact_person
      t.text :note

      t.timestamps
    end
  end
end
