class AddExpectedDeliveryDateToOrderItems < ActiveRecord::Migration[7.1]
  def change
    add_column :order_items, :expected_delivery_date, :date
  end
end
