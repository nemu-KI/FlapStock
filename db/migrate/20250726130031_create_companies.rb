class CreateCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
