require 'test_helper'

class OrderItemTest < ActiveSupport::TestCase
  test "the truth" do
    order_item = OrderItem.new
    refute order_item.valid?
    refute order_item.save

    assert_operator order_item.errors.count, :>, 0
    assert order_item.errors.messages[:amount].include?("can't be blank")
  end
end
