class AddUniqueValidationInProductToOrdersProducts2 < ActiveRecord::Migration[7.0]
  def change
    add_index :orders_products, [:product_id, :order_id], unique: true
  end
end
