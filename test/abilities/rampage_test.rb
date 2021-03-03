require 'test_helper'

class StrikeTest < ActiveSupport::TestCase

  test "Using a ability with a cooldown should trigger cooldown" do
    d1 = Dinosaur.new(health: 1000, damage: 100, speed: 130, name: 'd1', abilities: [Strike]).reset_attributes!
    d2 = Dinosaur.new(health: 1000, damage: 100, speed: 130, name: 'd2', abilities: [Rampage]).reset_attributes!
    d2.tick
    ability = d2.available_abilities.first
    ability.execute(d2, d1)
    d2.tick
    assert_equal([], d2.available_abilities)
    d2.tick
    assert_equal([Rampage], d2.available_abilities.map{|c| c.class})
  end

end
