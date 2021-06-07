require 'test_helper'

class DamageOverTimeTest < ActiveSupport::TestCase

  test "Dot should deal damage during tick" do
    defender = Dinosaur.new(health: 1000, speed: 125, name: 'defender', resistances: [0] * 9, abilities: []).reset_attributes!
    defender.add_modifier(Modifiers::DamageOverTime.new(33.4, 3))
    defender.tick
    assert_equal 666.0, defender.current_health
    defender.tick
    assert_in_delta 332.0, defender.current_health, 0.1
    defender.tick
    assert_in_delta -2.0, defender.current_health, 0.1
  end

  test "Dot should have no impact when immune" do
    defender = Dinosaur.new(health: 1000, speed: 125, name: 'defender', resistances: [0, 100, 0, 0, 0, 0, 0, 0, 0], abilities: []).reset_attributes!
    defender.add_modifier(Modifiers::DamageOverTime.new(33.4, 3))
    defender.tick
    assert_equal 1000, defender.current_health
  end

  test "Dot should be reduced when resistant" do
    defender = Dinosaur.new(health: 1000, speed: 125, name: 'defender', resistances: [0, 60, 0, 0, 0, 0, 0, 0, 0], abilities: []).reset_attributes!
    defender.add_modifier(Modifiers::DamageOverTime.new(33.4, 3))
    defender.tick
    assert_in_delta 866.4, defender.current_health, 0.1
  end

end
