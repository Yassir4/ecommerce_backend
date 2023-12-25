class OrdersController < ApplicationController
    before_action :authenticate_user!, only: [:create, :index]


    def create
        products = order_params[:products]

        if products.length > 0
            # TODO: add an error when a certain product is out of stock or the order quantity is less than the available quantity
            # the current behavior excludes the product if it's out of stock or uses the available quantity when the order quantity exceeds the available quantity
            order = current_user.orders.create
            paypal_response = {
                purchase_units: [
                    reference_id: "ref_#{order.id}",
                    items: [],
                    intent: 'CAPTURE'
                ]
            }
            products.each do |item|
                product = Product.find(item[:id])
                if (product.present? && product&.quantity > 0)
                    price = product.quantity >= item[:quantity] ? item[:quantity] * product.price : product.quantity * product.price
                    
                    quantity =  product.quantity >= item[:quantity] ? item[:quantity] : product.quantity
                    product.quantity -= quantity

                    paypal_response[:purchase_units][0][:items].push({   
                        name: product.name,
                        description: product.description,
                        unit_amount: {
                            currency_code: "USD",
                            value: product.price,
                        },
                        quantity: quantity
                    })
                    
                    # here I coudln't use the order.products as it returns an empty array.
                    order.orders_products.create(product: product, quantity: item[:quantity], price: price )
                     
                    order.total = (order.total || 0) + price
                    product.save

                end
            end

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

                    render json: {
                        status: {code: 200},
                        response: paypal_response
                    }
                    return
                end
                order.destroy
                render json: {
                    status: {code: 400},
                    errors: ['something went wront']
                }
                return
            end
        end
        render json: {
            status: {code: 400},
            errors: ['somethasdfing went wront']
        }
    end


    def index 
        render json: {
            orders: current_user.orders.map do |order| 
                {
                    id: order.id,
                    total: order.total || 0,
                    products_count: order&.products&.length || 0
                }
            end
            } 
    end



    private
    def order_params
        params.permit(orders: {}, products: [:id, :quantity])
    end

end
