require 'test_helper'

class FierceStrikeTest < ActiveSupport::TestCase

  test "Fierce strike should reduce defender's health by 1.5 attacker's damage, bypassing armor" do
    attacker = Dinosaur.new(damage: 500, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health: 1000, speed: 125, armor: 50, name: 'defender', abilities: []).reset_attributes!
    FierceStrike.new.execute(attacker, defender)
    assert_equal 250, defender.current_health
  end

end
