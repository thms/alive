require 'test_helper'

class CleansingStrikeTest < ActiveSupport::TestCase

  test "cleansing strike should cleanse speed decreases " do
    attacker = Dinosaur.new(health: 1000, damage: 100, speed: 130,  name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health: 1000, damage: 100, speed: 130, name: 'defender', abilities: []).reset_attributes!
    DeceleratingStrike.new.execute(attacker, defender)
    assert_equal 117, defender.current_speed
    CleansingStrike.new.execute(defender, attacker)
    assert_equal [], defender.modifiers
    assert_equal 130, defender.current_speed
  end

end
