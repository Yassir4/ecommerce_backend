class OrdersController < ApplicationController
    before_action :authenticate_user!, only: [:create, :index]

    # create an order with all the products
    def create
        products = order_params[:products]

        if products.length > 0
            order = current_user.orders.create
            products.each do |item|
                product = Product.find(item[:id])

                if (product.present?)
                    price = item[:quantity] * product.price
                    order.orders_products.create(product: product, quantity: item[:quantity], price: price )
                    order.total = (order.total || 0) + price
                end
                order.save
                # add else condition for missing products
            end
            render json: {
                status: {code: 200},
                order: order
            }
        else
            render json: {
                status: {code: 403},
                errors: ["Products are empty"]
            }
        end
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
