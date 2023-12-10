class AddUniqueValidationInProductToOrdersProducts < ActiveRecord::Migration[7.0]
  def change
    add_index :orders_products, [:product, :order], unique: true
  end
end
