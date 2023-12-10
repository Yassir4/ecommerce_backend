class ProductsController < ApplicationController
    before_action :authenticate_user!, only: [:create, :update, :destroy]

    def index  
        normalized_products = Product.all.map { |product|
            {
                name: product.name, 
                description: product.description,
                id: product.id, 
                is_author: product.user.id == current_user&.id,
                category: { name: product.category.name, id: product.category.id }
            }
        }

        render json: {
            products:  normalized_products
        }
    end
  
    def show 
        product = find_product(params[:id], false)
        normalized_product = {
            name: product.name, 
            description: product.description,
            id: product.id, 
            is_author: product.user.id == current_user&.id,
            category: { name: product.category.name, id: product.category.id }
        }
        render json: {
            status: {code: 200},
            product: normalized_product
        }
    end

    def create
        product = current_user.products.create(product_params)
        if product.errors.empty?
            render json: {
                status: {code: 200},
                product: product
            }
        else
            render json: {
                status: {code: 422, errors: product.errors},
            }
        end
    end

    def update
        product = find_product(params[:id])
        if product.update(product_params)
            render json: {
                status: { code: 200 },
                product: product
            }
        end
    end

    def destroy
        product = find_product(params[:id])
        if product.destroy
            render json: {
                status: { code: 200 }
            }
        end
    end

    def find_product(product_id, check_for_authorship = true)
        begin
            product = Product.find(product_id)
            if product.present?
                if ((product.user.id == current_user&.id && check_for_authorship) || !check_for_authorship)
                    return product
                else
                    render json: {
                        status: :unauthorized
                    }
                end
            end
        rescue ActiveRecord::RecordNotFound
            render json: {
                status: :not_found
            }
        end
        return
    end

    private

    def product_params
        params.require(:product).permit(:name, :description, :price, :category_id)
    end

  end
  