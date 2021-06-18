require 'test_helper'

class IncreaseCriticalChanceTest < ActiveSupport::TestCase

  test "Critical chance should be increased for one turn" do
    dinosaur = Dinosaur.new(damage_26: 500, level: 26, speed: 130, critical_chance: 20, name: 'attacker', abilities: []).reset_attributes!
    dinosaur.add_modifier(Modifiers::IncreaseCriticalChance.new(25, 1, 1))
    # takes effect immediately:
    assert_equal 45, dinosaur.current_attributes[:critical_chance]
    # still active for the next turn:
    dinosaur.tick
    assert_equal 45, dinosaur.current_attributes[:critical_chance]
    # gone for the turn after that:
    dinosaur.tick
    assert_equal 20, dinosaur.current_attributes[:critical_chance]
  end

  test "Critical chance increase should tick down each time it is used" do
    attacker = Dinosaur.new(damage_26: 500, level: 26, health_26: 2000, speed: 130, critical_chance: 20, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(damage_26: 500, level: 26, health_26: 2000, speed: 130, critical_chance: 20, name: 'defender', abilities: []).reset_attributes!
    attacker.add_modifier(Modifiers::IncreaseCriticalChance.new(25, 4, 2))
    assert_equal 2, attacker.modifiers.first.current_attacks
    Strike.new.execute(attacker, defender)
    assert_equal 1, attacker.modifiers.first.current_attacks
    Strike.new.execute(attacker, defender)
    assert_equal 0, attacker.modifiers.first.current_attacks
  end
end
