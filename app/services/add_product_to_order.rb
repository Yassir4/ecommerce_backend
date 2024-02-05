class AddProductToOrder
    def initialize(order, product, product_order_quantity) 
        @order = order
        @product = product
        @product_order_quantity = product_order_quantity
    end

    def call
        # calculate the order quantity 
        # return the paypal data of the product
        if @product.present? && @product.quantity > 0
            quantity =  @product.quantity >= @product_order_quantity ? @product_order_quantity : @product.quantity
            
            paypal_item = {
                name: @product.name,
                description: @product.description,
                unit_amount: {
                    currency_code: "USD",
                    value: @product.price,
                },
                quantity: quantity
            }

            
            @order.add_product(@product, quantity)

            return paypal_item
        end
        return false
    end
end