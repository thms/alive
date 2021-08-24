require 'test_helper'

class CleansingStrikeTest < ActiveSupport::TestCase

  test "cleansing strike should cleanse speed decreases " do
    attacker = Dinosaur.new(health_26: 1000, damage_26: 100, level: 26, speed: 130,  name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health_26: 1000, damage_26: 100, level: 26, speed: 130, name: 'defender', abilities: []).reset_attributes!
    DeceleratingImpact.new.execute(attacker, defender)
    assert_equal 65, defender.current_speed
    CleansingStrike.new.execute(defender, attacker)
    assert_equal [], defender.modifiers
    assert_equal 130, defender.current_speed
  end

end
