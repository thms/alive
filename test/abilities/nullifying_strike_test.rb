require 'test_helper'

class NullifyingStrikeTest < ActiveSupport::TestCase

  test "nullifyng strike should remove defnder's positive effects" do
    attacker = Dinosaur.new(damage_26: 100, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health_26: 1000, level: 26, speed: 125, name: 'defender', abilities: []).reset_attributes!
    defender.add_modifier(Modifiers::Shields.new(50, 1, 1))
    NullifyingStrike.new.execute(attacker, defender)
    assert_equal 900, defender.current_health
    assert_equal [], defender.modifiers
  end


end
