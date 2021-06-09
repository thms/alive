require 'test_helper'

class DamageOverTimeTest < ActiveSupport::TestCase

  test "Dot should deal damage during tick" do
    defender = Dinosaur.new(health: 1000, speed: 125, name: 'defender', resistances: [0] * 9, abilities: []).reset_attributes!
    defender.add_modifier(Modifiers::DamageOverTime.new(33.4, 3))
    defender.tick
    assert_equal 666, defender.current_health
    defender.tick
    assert_equal 332, defender.current_health
    defender.tick
    assert_equal -2, defender.current_health
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
    assert_equal 866, defender.current_health
  end

end
