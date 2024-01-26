class OrdersController < ApplicationController
    before_action :authenticate_user!, only: [:create, :index]
    before_action :user_has_permission, only: [:update]

    def create
        products = order_params[:products]
        paypal_response = {}
        order_id = ''
        if products.length > 0

            ActiveRecord::Base.transaction do
                # TODO: add an error when a certain product is out of stock or the order quantity is less than the available quantity
                # the current behavior excludes the product if it's out of stock or uses the available quantity when the order quantity exceeds the available quantity
                order = current_user.orders.create
                order_id = order.id
                paypal_response = {
                    purchase_units: [
                        reference_id: "ref_#{order_id}",
                        items: [],
                        intent: 'CAPTURE'
                    ]
                }
                begin
                    products.each do |item|
                        product = Product.lock.find(item[:id])
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
                            product.save!

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
                        else
                            render json: {
                                status: {code: 400},
                                errors: ['something went wront', order]
                            }
                            return
                        end
                    end
                    
                rescue
                    render json: {
                        status: {code: 400},
                        errors: ['something went wront', order]
                    }
                    raise ActiveRecord::Rollback
                    return
                end
            end
        else 
            render json: {
                status: {code: 400},
                errors: ["products can't be empty"]
            }
            return
        end
        render_order_data(order_id, paypal_response)
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

    def render_order_data(order_id, paypal_response)
        render json: {
            status: {code: 200},
            response: paypal_response,
            order_id: order_id
        }
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
