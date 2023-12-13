class RemoveUnusedOrderProductIndex < ActiveRecord::Migration[7.0]
  def change
    remove_index :orders_products, name: "index_orders_products_on_product_and_order"
  end
end
