class OrdersController < ApplicationController
  before_action :set_user
  before_action :set_order, only: [:show]
  before_action :set_basket, only: [:basket, :add, :purchase, :clear]

  # GET /users/:user_id/orders
  def index
    @orders = @user.orders.where(order_type: 'order').order("updated_at DESC")

    render json: json_response(@orders)
  end

  # GET /users/:user_id/orders/1
  def show
    render json: json_response_with_include(@order, @order.order_items)
  end

  # PATH /users/:user_id/basket

  # GET /users/:user_id/basket
  def basket
    render json: json_response_with_include(@basket, @basket.order_items)
  end

  # POST /users/:user_id/basket/add
  def add
    if check_inventory && @basket.update(order_params)
      render json: json_response_with_include(@basket, @basket.order_items)
    else
      render json: json_response(@basket.errors, '422'), status: :unprocessable_entity
    end
  end

  # POST /users/:user_id/basket/purchase
  def purchase
    if update_products && @basket.update(order_type: 'order')
      # after purchase users' basket updated as order and new basket is created
      create_new_basket
      render json: json_response_with_include(@basket, @basket.order_items)
    else
      render json: json_response(@basket.errors, '422'), status: :unprocessable_entity
    end
  end

  # DELETE /users/:user_id/basket/clear
  def clear
    if @basket.order_items.destroy_all
      render json: json_response_with_include(@basket, @basket.order_items)
    else
      render json: json_response(@basket.errors, '422'), status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:user_id])
    end

    def set_order
      @order = @user.orders.find(params[:id])
    end

    def set_basket
      @basket = @user.orders.where(order_type: 'basket').last
    end

    # Only allow a trusted parameter "white list" through.
    def order_params
      params.require(:order).permit(order_items_attributes: [:amount, :product_id])
    end

    def add_basket_error(error)
      @basket.errors["order_items"] << "#{error}"
    end

    def check_amount_errors(amount)
      if amount.nil?
        add_basket_error("amount must exist")
      elsif amount.to_i < 1
        add_basket_error("amount(#{amount}) should be positive integer")
      end
    end

    def check_product_errors(product_id, amount)
      if product = Product.where(id: product_id).first
        if amount.to_i > product.inventory
          add_basket_error("product ##{product_id} is out of stock, only #{product.inventory} in inventory")
        end
      else
        add_basket_error("product ##{product_id} must exist")
      end
    end

    # checks attributes, add errors if exist and returns boolean
    def check_inventory
      order_params

      params[:order][:order_items_attributes].each do |order_items_attributes|
        amount = order_items_attributes[1][:amount]
        product_id = order_items_attributes[1][:product_id]

        check_amount_errors(amount)
        check_product_errors(product_id, amount)
      end

      return true unless @basket.errors.present?
    end

    def create_new_basket
      Order.create(user_id: params[:user_id])
    end

    # does product transaction update and if there is an error it rollbacks changes
    def update_products
      Product.transaction do
        @basket.order_items.each do |order_item|
          product = order_item.product

          if product.inventory < order_item.amount
            add_basket_error("product ##{product.id} is out of stock, only #{product.inventory} in inventory")
            raise ActiveRecord::Rollback, "Rollback product changes"
            return false
          else
            product.inventory -= order_item.amount
            product.save
          end
        end
      end
    end
end
