require 'test_helper'

class RaidTest < ActiveSupport::TestCase

  test "In raid an ability should target the highest " do
    d1 = Dinosaur.new(health_26: 1000, damage_26: 100, speed: 130, level: 20, name: 'd1', abilities: [Strike], strategy: DefaultStrategy)
    d2 = Dinosaur.new(health_26: 1000, damage_26: 100, speed: 125, level: 20, name: 'd2', abilities: [Strike], strategy: DefaultStrategy)
    match = Match.new(d1, d2)
    d1.pick_ability(d1, d2)
    d2.pick_ability(d2, d1)
    result = Mechanics.order_dinosaurs([d1, d2])
    assert_equal 'd1', result.first.name
  end
end
