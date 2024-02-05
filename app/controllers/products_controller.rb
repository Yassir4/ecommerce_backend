class ProductsController < ApplicationController
    before_action :authenticate_user!, only: [:create, :update, :destroy]
    before_action :user_has_permission, only: [:update, :destroy]


    def index  
        normalized_products = Product.all.map { |product|
            {
                name: product.name, 
                description: product.description,
                id: product.id, 
                is_author: product.user.id == current_user&.id,
                category: { name: product.category.name, id: product.category.id },
                user_can_edit: current_user ? user_has_permission(product.id) : false,
                quantity: product.quantity
            }
        }
        render json: {
            products: normalized_products
        }
    end

    def show
        product = find_product(params[:id])
        if product&.present?
            normalized_product = {
                name: product.name, 
                description: product.description,
                id: product.id, 
                is_author: product&.user&.id == current_user&.id,
                category: { name: product.category.name, id: product.category.id },
                user_can_edit: current_user ? user_has_permission(product.id) : false,
                quantity: product.quantity,
                price: product.price
            }
            render json: {
                status: {code: 200},
                product: normalized_product
            }, status: 200
        end
    end

    def create
        product = current_user.products.create(product_params)
        if product.errors.empty?
            render json: {
                status: {code: 200},
                product: product
            }, status: 200
        else
            render json: {
                status: {errors: product.errors},
            }, status: 422
        end
    end

    def update
        product = find_product(params[:id])
        if product.update(product_params)
            render json: {
                status: { code: 200 },
                product: product
            }
        else 
            render json: {
                status: { code: 400 }, status: 400
            }
        end
    end

    def destroy
        product = find_product(params[:id])
        if product.destroy
            render json: {
                status: { code: 200 }
            }, status: 200
        end
    end

    def find_product(product_id)
        begin
            product = Product.find(product_id)
            if product.present?
                return product
            end
        rescue ActiveRecord::RecordNotFound
            render json: {
                status: :not_found
            }, status: :not_found
        end
    end

    private

    def product_params
        params.require(:product).permit(:name, :description, :price, :category_id, :quantity)
    end

    def user_has_permission(product_id = params[:id])
        product = find_product(product_id)
        if product.present?
            if ((product.user.id == current_user&.id) || current_user&.admin)
                return true
            else
                render json: {
                    status: :not_found
                }, status: :unauthorized
            end
        end
        return false
    end
end
  