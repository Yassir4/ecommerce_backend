class ProductsController < ApplicationController
    before_action :authenticate_user!, only: [:create, :update]

    def index
      render json: Product.all
    end
  
    def show 
        product = find_product(params[:id])
        render json: {
            status: {code: 200},
            product: product
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
                status: { code: 200 }
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

    def find_product(product_id)
        begin
            product = Product.find(product_id)
            if product.present?
                if product.user.id == current_user.id
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
        params.require(:product).permit(:name, :description, :price)
    end

  end
  