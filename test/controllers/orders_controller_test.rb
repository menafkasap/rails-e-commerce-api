require 'test_helper'

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @order = orders(:one)
    @basket = orders(:two)
  end

  # happy paths

  test "should get index" do
    assert_routing "/users/1/orders", controller: 'orders', action: 'index', user_id: '1'

    get user_orders_url(@user), as: :json
    assert_response :success

    response_body = JSON.parse(@response.body)

    assert_equal(1, response_body['data'].count)
    assert_equal('order', response_body['data'][0]['order_type'])
  end

  test "should show order" do
    assert_routing "/users/1/orders/1", controller: 'orders', action: 'show', user_id: '1', id: '1'

    get user_order_url(@user, @order), as: :json
    assert_response :success

    response_body = JSON.parse(@response.body)
    assert_equal('order', response_body['data']['order_type'])
  end

  test "should show basket" do
    assert_routing "/users/1/basket", controller: 'orders', action: 'basket', user_id: '1'

    get "/users/#{@user.id}/basket"
    assert_response :success

    response_body = JSON.parse(@response.body)
    assert_equal('basket', response_body['data']['order_type'])
    assert_equal(1, response_body['includes'].count)
  end

  test "should add order items to basket" do
    product = products(:one)

    assert_difference('OrderItem.count') do
      post "/users/#{@user.id}/basket/add", params: {
        order: {
          order_items_attributes: { '0': { amount: "2", product_id: "#{product.id}" } }
        }
      }
      assert_response :success

      response_body = JSON.parse(@response.body)
      assert_equal(2, response_body['includes'].count)
    end
  end

  test "should clear order items at basket" do
    assert_difference('OrderItem.count', -1) do
      delete "/users/#{@user.id}/basket/clear"
      assert_response :success

      response_body = JSON.parse(@response.body)
      assert_equal(0, response_body['includes'].count)
    end
  end

  test "should purchase order items at basket" do
    # new basket will be created after purchase
    assert_difference('Order.count') do
      post "/users/#{@user.id}/basket/purchase"
      assert_response :success

      response_body = JSON.parse(@response.body)
      assert_equal('order', response_body['data']['order_type'])
      assert_equal(1, response_body['includes'].count)

      # product's inventory was 10 before purchase
      product = products(:one)
      assert_equal(9, product.inventory)
    end
  end

  # fails

  test "should get error when user does not exist" do
    error = assert_raises ActiveRecord::RecordNotFound do
      get user_orders_url(1), as: :json
      assert_response :error
    end
    assert_match("Couldn't find User", error.to_s)
  end

  test "should get error when order does not exist" do
    error = assert_raises ActiveRecord::RecordNotFound do
      get user_order_url(@user, 1), as: :json
      assert_response :error
    end
    assert_match("Couldn't find Order", error.to_s)
  end

  test "should get error when order does not belong to another user" do
     another_user = users(:two)
     error = assert_raises ActiveRecord::RecordNotFound do
      get user_order_url(another_user, @order), as: :json
      assert_response :error
    end
    assert_match("Couldn't find Order", error.to_s)
  end

  test "should get amount error when adding order items to basket" do
    product = products(:one)

    assert_difference('OrderItem.count', 0) do
      post "/users/#{@user.id}/basket/add", params: {
        order: {
          order_items_attributes: { '0': { amount: "asd", product_id: "#{product.id}" } }
        }
      }
      assert_response :unprocessable_entity

      response_body = JSON.parse(@response.body)
      assert_equal('amount(asd) should be positive integer', response_body['data']['order_items'][0])
    end
  end

  test "should get product error when adding order items to basket" do
    assert_difference('OrderItem.count', 0) do
      post "/users/#{@user.id}/basket/add", params: {
        order: {
          order_items_attributes: { '0': { amount: "2", product_id: "1" } }
        }
      }
      assert_response :unprocessable_entity

      response_body = JSON.parse(@response.body)
      assert_equal('product #1 must exist', response_body['data']['order_items'][0])
    end
  end

  test "should get insufficient stock error when adding order items to basket" do
    product = products(:two)
    assert_difference('OrderItem.count', 0) do
      post "/users/#{@user.id}/basket/add", params: {
        order: {
          order_items_attributes: { '0': { amount: "12", product_id: "#{product.id}" } }
        }
      }
      assert_response :unprocessable_entity

      response_body = JSON.parse(@response.body)
      assert_equal(
        "product ##{product.id} is out of stock, only 0 in inventory",
        response_body['data']['order_items'][0]
      )
    end
  end

  test "should get insufficient stock error when purchase order items at basket" do
    assert_difference('Order.count', 0) do
      product = products(:one)
      product.inventory = 0
      product.save

      post "/users/#{@user.id}/basket/purchase"
      assert_response :unprocessable_entity

      response_body = JSON.parse(@response.body)
      assert_equal(
        "product ##{product.id} is out of stock, only 0 in inventory",
        response_body['data']['order_items'][0]
      )
    end
  end
end
