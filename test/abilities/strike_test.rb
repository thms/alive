require 'test_helper'

class StrikeTest < ActiveSupport::TestCase

  test "strike should reduce defender's health by attacker's damage" do
    attacker = Dinosaur.new(damage: 100, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health: 1000, speed: 125, name: 'defender', abilities: []).reset_attributes!
    Strike.new.execute(attacker, defender)
    assert_equal 900, defender.current_health
  end

end
