class OrdersProduct < ApplicationRecord
    belongs_to :order
    belongs_to :product
    validates :order, uniqueness: { scope: :product } 
    after_create :update_product_quantity

    def update_product_quantity
        pro = self.product
        pro.quantity -= self.quantity
        pro.save
    end
end