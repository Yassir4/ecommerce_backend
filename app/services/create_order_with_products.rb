class CreateOrderWithProducts
    def initialize(products, current_user) 
        @products = products
        @current_user = current_user
    end

    def call
        paypal_response = {}
        response = {}
        ActiveRecord::Base.transaction do
            # TODO: add an error when a certain product is out of stock or the order quantity is less than the available quantity
            # the current behavior excludes the product if it's out of stock or uses the available quantity when the order quantity exceeds the available quantity
            order = @current_user.orders.create
            order_id = order.id
            paypal_response = {
                purchase_units: [
                    reference_id: "ref_#{order_id}",
                    items: [],
                    intent: 'CAPTURE'
                ]
            }
            begin
                @products.each do |item|
                    product = Product.lock.find(item[:id])
                    paypal_item = AddProductToOrder.new(order, product, item[:quantity]).call
                    if paypal_item
                        paypal_response[:purchase_units][0][:items].push(paypal_item)
                    else
                        raise ActiveRecord::Rollback
                        return  {
                            status: {code: 400},
                            errors: ['something went wrong']
                        }
                    end
                end
                
                total = calculate_total(order)
                order.total = total

                if order.save!
                    
                    if order.orders_products.length > 0
                        paypal_response[:purchase_units][0][:amount] = {
                            currency_code: "USD",
                            value: order.total,
                            breakdown: {
                                item_total: {
                                    currency_code: "USD",
                                    value: order.total,
                                }
                            }
                        }
                        
                        response = return_order_data(order.id, paypal_response)
                    end
                end
            rescue => e
                return {
                    status: {code: 400},
                    errors: ['something went wrong', order]
                }
                raise ActiveRecord::Rollback
            end
        end
        return response
    end

    private

    def calculate_total(order)
        current_total = 0
        order.orders_products.each do |product|
          # change this after adding the product unique constraint
          current_total += product.price  || 0
        end
        current_total
    end


    def return_order_data(order_id, paypal_response)
        {
            status: {code: 200},
            response: paypal_response,
            order_id: order_id
        }
    end
end