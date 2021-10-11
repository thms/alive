require 'test_helper'
require 'boss'

class BossTest < ActiveSupport::TestCase

  test "reset_attribites! should inflate abilities from classes to instances" do
    boss = Boss.find_by_name("Bajadasaurs Boss")
    assert_equal Class, boss.abililities.first.first.class
    boss.reset_attributes!
    assert_equal Bellow, boss.abililities.first.first.class
  end
end
