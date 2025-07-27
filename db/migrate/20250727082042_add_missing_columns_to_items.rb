class AddMissingColumnsToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :description, :text
    add_column :items, :sku, :string
    add_column :items, :image_url, :string
    add_column :items, :min_stock, :integer
    add_column :items, :max_stock, :integer
  end
end
