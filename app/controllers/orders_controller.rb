class OrdersController < ApplicationController
    before_action :authenticate_user!, only: [:create, :index]
    before_action :user_has_permission, only: [:update]

    def create
        products = order_params[:products]
        order_id = ''
        if products.length > 0
            response = CreateOrderWithProducts.new(products, current_user).call
            
            if response
                render json: response
            else
                render json: { 
                    status: {code: 400},
                    errors: ['something went wrong', order]
                }
            end   
        else 
            render json: {
                status: {code: 400},
                errors: ["products can't be empty"]
            }
        end
    end


    def index 
        render json: {
            orders: current_user.orders.where(status: "paid").map do |order| 
                {
                    id: order.id,
                    total: order.total || 0,
                    createdAt: order.created_at,
                    products: order&.orders_products.map do |order_product|
                        product = Product.find(order_product.product_id)
                        {
                            name: product.name,
                            quantity: order_product.quantity,
                            price: order_product.price
                        } 
                    end
                }
            end
        }
    end

    def update
        order_id = params[:id]
        if params[:id]
            begin
                order = Order.find(order_id)
                if order.present? && order.update_column(:status, update_order_params[:status])
                    render json: {
                        status: { code: 200 },
                        order: order
                    }
                end
            rescue ActiveRecord::RecordNotFound
                render json: {
                    status: :not_found
                }
            end
        end
    end

    private
    def order_params
        params.permit(orders: {}, products: [:id, :quantity])
    end

    

    def update_order_params
        params.require(:order).permit(:status)
    end

    def user_has_permission(order_id = params[:id])
        if !order_id
             return false
        end
        order = Order.find(order_id)
        if order.present?
            if ((order.user.id == current_user&.id) || current_user&.admin)
                return true
            else
                render json: {
                    errors: ["Unauthorized action"]
                }, status: :unauthorized
            end
        else
            render status: :not_found
        end
        return false
    end
end
