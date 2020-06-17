class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :update, :destroy]

  # GET /products
  def index
    @products = Product.all

    render json: json_response(@products)
  end

  # GET /products/1
  def show
    render json: json_response(@product)
  end

  # POST /products
  def create
    @product = Product.new(product_params)

    if @product.save
      render json: json_response(@product, '201'), status: :created, location: @product
    else
      render json: json_response(@product.errors, '422'), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /products/1
  def update
    if @product.update(product_params)
      render json: json_response(@product)
    else
      render json: json_response(@product.errors, '422'), status: :unprocessable_entity
    end
  end

  # DELETE /products/1
  def destroy
    @product.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def product_params
      params.require(:product).permit(:name, :price, :inventory)
    end
end
