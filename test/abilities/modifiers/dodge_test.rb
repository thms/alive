require 'test_helper'

class DodgeTest < ActiveSupport::TestCase

  test "Dodge should reduce the damage taken or not" do
    attacker = Dinosaur.new(damage_26: 500, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health_26: 1000, level: 26, speed: 125, name: 'defender', abilities: []).reset_attributes!
    defender.add_modifier(Modifiers::Dodge.new(75, 1, 1))
    Strike.new.execute(attacker, defender)
    assert_includes [500, 834], defender.current_health
  end

  test "Dodge should reduce the damage taken with a certain probability" do
    cumulative_health = 0
    num_of_dodges = 0
    100.times do
      attacker = Dinosaur.new(damage_26: 500, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
      defender = Dinosaur.new(health_26: 1000, level: 26, speed: 125, name: 'defender', abilities: []).reset_attributes!
      defender.add_modifier(Modifiers::Dodge.new(75, 1, 1))
      stats = Strike.new.execute(attacker, defender)
      cumulative_health += defender.current_health
      num_of_dodges += 1 if stats[:did_dodge]
    end
    assert_in_delta 75, num_of_dodges, 10
    assert_in_delta 75 * 834 + 25 * 500, cumulative_health, 334*10
  end


  test "Dodge should tick down with each hit taken" do
    attacker = Dinosaur.new(damage_26: 500, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health_26: 1000, level: 26, speed: 125, name: 'defender', abilities: []).reset_attributes!
    defender.add_modifier(Modifiers::Dodge.new(50, 4, 2))
    assert_equal 2, defender.modifiers.first.current_attacks
    Strike.new.execute(attacker, defender)
    assert_equal 1, defender.modifiers.first.current_attacks
    Strike.new.execute(attacker, defender)
    assert_equal [], defender.modifiers
  end

  test "Dodge should be bypassed by precise atttack" do
    skip
  end


end
