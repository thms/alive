require 'test_helper'

class ShieldsTest < ActiveSupport::TestCase

  test "Shields should reduce the damage taken" do
    attacker = Dinosaur.new(damage_26: 500, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health_26: 1000, level: 26, speed: 125, name: 'defender', abilities: []).reset_attributes!
    defender.add_modifier(Modifiers::Shields.new(50, 1, 1))
    Strike.new.execute(attacker, defender)
    assert_equal 750, defender.current_health
  end

  test "Shields should not be additive but rather use the max the damage taken" do
    attacker = Dinosaur.new(damage_26: 500, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health_26: 1000, level: 26, speed: 125, name: 'defender', abilities: []).reset_attributes!
    defender.add_modifier(Modifiers::Shields.new(50, 1, 1))
    defender.add_modifier(Modifiers::Shields.new(75, 1, 1))
    Strike.new.execute(attacker, defender)
    assert_equal 875, defender.current_health
  end

  test "Shields should tick down with each hit taken" do
    attacker = Dinosaur.new(damage_26: 500, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health_26: 1000, level: 26, speed: 125, name: 'defender', abilities: []).reset_attributes!
    defender.add_modifier(Modifiers::Shields.new(50, 4, 2))
    assert_equal 2, defender.modifiers.first.current_attacks
    Strike.new.execute(attacker, defender)
    assert_equal 1, defender.modifiers.first.current_attacks
    Strike.new.execute(attacker, defender)
    assert_equal [], defender.modifiers
  end


end
