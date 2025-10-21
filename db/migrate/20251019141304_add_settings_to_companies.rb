class AddSettingsToCompanies < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :address, :string
    add_column :companies, :timezone, :string, default: 'Tokyo'
  end
end
