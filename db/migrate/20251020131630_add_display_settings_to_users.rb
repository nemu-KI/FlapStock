class AddDisplaySettingsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :per_page, :integer
    add_column :users, :default_sort, :string
    add_column :users, :date_format, :string
    add_column :users, :number_format, :string
  end
end
