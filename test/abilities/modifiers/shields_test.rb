require 'test_helper'

class ShieldsTest < ActiveSupport::TestCase

  test "Shields should reduce the damage taken" do
    attacker = Dinosaur.new(damage: 500, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health: 1000, speed: 125, name: 'defender', abilities: []).reset_attributes!
    defender.add_modifier(Modifiers::Shields.new(50, 1, 1))
    Strike.new.execute(attacker, defender)
    assert_equal 750, defender.current_health
  end

  test "Shields should be additive the damage taken" do
    attacker = Dinosaur.new(damage: 500, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health: 1000, speed: 125, name: 'defender', abilities: []).reset_attributes!
    defender.add_modifier(Modifiers::Shields.new(50, 1, 1))
    defender.add_modifier(Modifiers::Shields.new(50, 1, 1))
    Strike.new.execute(attacker, defender)
    assert_equal 1000, defender.current_health
  end


end
