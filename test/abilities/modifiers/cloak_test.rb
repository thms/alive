require 'test_helper'

class CloakTest < ActiveSupport::TestCase

  test "Cloak should reduce the damage taken or not" do
    attacker = Dinosaur.new(damage_26: 500, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health_26: 1000, level: 26, speed: 125, name: 'defender', abilities: []).reset_attributes!
    defender.add_modifier(Modifiers::Cloak.new(75, 200, 1, 1))
    Strike.new.execute(attacker, defender)
    assert_includes [500, 834], defender.current_health
  end

  test "Cloak should reduce the damage taken with a certain probability" do
    cumulative_health = 0
    num_of_dodges = 0
    100.times do
      attacker = Dinosaur.new(damage_26: 500, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
      defender = Dinosaur.new(health_26: 1000, level: 26, speed: 125, name: 'defender', abilities: []).reset_attributes!
      defender.add_modifier(Modifiers::Cloak.new(75, 200, 1, 1))
      stats = Strike.new.execute(attacker, defender)
      cumulative_health += defender.current_health
      num_of_dodges += 1 if stats[:did_dodge]
    end
    assert_in_delta 75, num_of_dodges, 10
    assert_in_delta 75 * 834 + 25 * 500, cumulative_health, 334*10
  end


  test "Cloak should be removed after first attack on other" do
    attacker = Dinosaur.new(damage_26: 500, level: 26, speed: 130, name: 'attacker', abilities: []).reset_attributes!
    defender = Dinosaur.new(health_26: 1000, level: 26, speed: 125, name: 'defender', abilities: []).reset_attributes!
    attacker.add_modifier(Modifiers::Cloak.new(50, 200, 1, 1))
    Strike.new.execute(attacker, defender)
    assert_equal [], attacker.modifiers
  end

  test "Dodge should be bypassed by precise atttack" do
    skip
  end


end
