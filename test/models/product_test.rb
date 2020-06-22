require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  test "the truth" do
    product = Product.new
    refute product.valid?
    refute product.save

    assert_operator product.errors.count, :>, 0
    assert product.errors.messages[:name].include?("can't be blank")
    assert product.errors.messages[:price].include?("can't be blank")
  end
end
