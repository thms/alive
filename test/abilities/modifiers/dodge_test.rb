require 'test_helper'

class DodgeTest < ActiveSupport::TestCase

  test "Dodge should reduce the damage taken or not" do
    attacker = Dinosaur.new(damage: 500, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health: 1000, speed: 125, name: 'defender', abilities: []).reset_attributes!
    defender.add_modifier(Modifiers::Dodge.new(75, 1, 1))
    Strike.new.execute(attacker, defender)
    assert_includes [500, 835], defender.current_health
  end

  test "Dodge should reduce the damage taken with a certain probability" do
    cumulative_health = 0
    100.times do
      attacker = Dinosaur.new(damage: 500, speed: 130, name: 'attacker', abilities: []).reset_attributes!
      defender = Dinosaur.new(health: 1000, speed: 125, name: 'defender', abilities: []).reset_attributes!
      defender.add_modifier(Modifiers::Dodge.new(75, 1, 1))
      Strike.new.execute(attacker, defender)
      cumulative_health += defender.current_health
    end
    assert_in_delta 75 * 835 + 25 * 500, cumulative_health, 2000
  end


  test "Dodge should tick down with each hit taken" do
    attacker = Dinosaur.new(damage: 500, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health: 1000, speed: 125, name: 'defender', abilities: []).reset_attributes!
    defender.add_modifier(Modifiers::Dodge.new(50, 4, 2))
    assert_equal 2, defender.modifiers.first.current_attacks
    Strike.new.execute(attacker, defender)
    assert_equal 1, defender.modifiers.first.current_attacks
    Strike.new.execute(attacker, defender)
    assert_equal 0, defender.modifiers.first.current_attacks
  end

  test "Dodge should be bypassed by precise atttack" do
    skip
  end


end
