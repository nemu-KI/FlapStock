class CreateContacts < ActiveRecord::Migration[7.1]
  def change
    create_table :contacts do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :category, null: false
      t.string :priority, default: 'medium'
      t.string :status, default: 'pending'
      t.string :subject, null: false
      t.text :message, null: false
      t.references :user, null: true, foreign_key: true
      t.references :company, null: true, foreign_key: true

      t.timestamps
    end

    add_index :contacts, :category
    add_index :contacts, :priority
    add_index :contacts, :status
    add_index :contacts, :created_at
  end
end
