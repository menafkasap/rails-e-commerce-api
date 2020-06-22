require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "the truth" do
    user = User.new
    refute user.valid?
    refute user.save

    assert_operator user.errors.count, :>, 0
    assert user.errors.messages[:email].include?("can't be blank")
    assert user.errors.messages[:first_name].include?("can't be blank")
    assert user.errors.messages[:last_name].include?("can't be blank")
    assert user.errors.messages[:phone].include?("can't be blank")
  end
end
