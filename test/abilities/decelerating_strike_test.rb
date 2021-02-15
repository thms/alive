require 'test_helper'

class DeceleratingStrikeTest < ActiveSupport::TestCase

  test "strike should reduce defender's health by attacker's damage and speed by 10%" do
    attacker = Dinosaur.new(damage: 100, speed: 130, name: 'attacker').reset_attributes!
    defender = Dinosaur.new(health: 1000, speed: 125, name: 'defender').reset_attributes!
    DeceleratingStrike.new(attacker, defender).execute
    assert_equal 900, defender.current_health
    assert_equal 112, defender.current_speed
  end

end
