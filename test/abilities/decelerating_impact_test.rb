require 'test_helper'

class DeceleratingImpactTest < ActiveSupport::TestCase

  test "decelerating impact should reduce defender's health by attacker's damage and speed by 10%" do
    attacker = Dinosaur.new(damage_26: 100, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health_26: 1000, level: 26, speed: 125, name: 'defender', abilities: []).reset_attributes!
    DeceleratingImpact.new.execute(attacker, defender)
    assert_equal 850, defender.current_health
    assert_equal 62, defender.current_speed
    defender.tick
    assert_equal 62, defender.current_speed
  end

end
