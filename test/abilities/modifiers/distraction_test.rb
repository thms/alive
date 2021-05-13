require 'test_helper'

class DistractionTest < ActiveSupport::TestCase

  test "Distraction should reduce the damage taken " do
    attacker = Dinosaur.new(damage: 500, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health: 1000, speed: 125, name: 'defender', abilities: []).reset_attributes!
    attacker.add_modifier(Modifiers::Distraction.new(75, 1, 1))
    Strike.new.execute(attacker, defender)
    assert_equal 875, defender.current_health
  end

end
