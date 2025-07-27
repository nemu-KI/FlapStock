class AddCompanyToCategoryLocationSupplierItemUser < ActiveRecord::Migration[7.1]
  def change
    add_reference :categories, :company, null: false, foreign_key: true
    add_reference :locations, :company, null: false, foreign_key: true
    add_reference :suppliers, :company, null: false, foreign_key: true
    add_reference :items, :company, null: false, foreign_key: true
    add_reference :users, :company, foreign_key: true
  end
end
