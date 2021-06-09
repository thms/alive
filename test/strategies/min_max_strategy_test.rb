require 'test_helper'

class MinMaxStrategyTest < ActiveSupport::TestCase

  test "MinMax Strategy should find strongest move even when there is no guarantee of a win" do
    #skip
    attacker = Dinosaur.new(
      value: 1.0,
      level: 26,
      health: 4500,
      damage: 1700,
      speed: 105,
      armor: 0,
      critical_chance: 40,
      name: 'Thoradolosaur',
      abilities: [FierceStrike, FierceImpact, GroupShatteringRampage, InstantCharge]).reset_attributes!
    defender = Dinosaur.new(
      value: -1.0,
      level: 26,
      health: 1650,
      damage: 1550,
      speed: 132,
      armor: 0,
      critical_chance: 5,
      name: 'Velociraptor',
      abilities: [Strike, HighPounce]).reset_attributes!

    result = MinMaxStrategy.next_move(attacker, defender)
    assert_equal FierceImpact, result.class
  end

  test "MinMax Strategy should find strongest move when there is a clear path to victory" do
    #skip
    defender = Dinosaur.new(
      value: -1.0,
      level: 26,
      health: 4500,
      damage: 1700,
      speed: 105,
      armor: 0,
      critical_chance: 40,
      name: 'Thoradolosaur',
      abilities: [FierceStrike, FierceImpact, GroupShatteringRampage, InstantCharge]).reset_attributes!
    attacker = Dinosaur.new(
      value: 1.0,
      level: 26,
      health: 1650,
      damage: 1550,
      speed: 132,
      armor: 0,
      critical_chance: 5,
      name: 'Velociraptor',
      abilities: [Strike, HighPounce]).reset_attributes!

    result = MinMaxStrategy.next_move(attacker, defender)
    assert_equal HighPounce, result.class
  end

  test "MinMax Strategy should use damage over time" do
    #skip
    attacker = Dinosaur.new(
      value: 1.0,
      level: 26,
      health: 4500,
      damage: 1300,
      speed: 116,
      armor: 0,
      critical_chance: 20,
      name: 'Suchotator',
      abilities: [SuperiorityStrike, LethalWound, NullifyingImpact, InstantDistraction]).reset_attributes!
    defender = Dinosaur.new(
      value: -1.0,
      level: 26,
      health: 1650,
      damage: 1550,
      speed: 132,
      armor: 0,
      critical_chance: 5,
      name: 'Velociraptor',
      abilities: [Strike, HighPounce]).reset_attributes!
      MinMaxStrategy.reset_cache
    result = MinMaxStrategy.next_move(attacker, defender)
    assert_equal InstantDistraction, result.class

  end

  test "MinMax Strategy should find a good move for Quetzorion" do
    #skip
    defender = Dinosaur.new(
      value: -1.0,
      level: 26,
      health: 4500,
      damage: 1700,
      speed: 105,
      armor: 0,
      critical_chance: 40,
      name: 'Thoradolosaur',
      abilities: [FierceStrike, FierceImpact, GroupShatteringRampage, InstantCharge]).reset_attributes!
    attacker = Dinosaur.new(
      value: 1.0,
      level: 26,
      health: 4200,
      damage: 1450,
      speed: 130,
      armor: 0,
      critical_chance: 20,
      name: 'Quetzorion',
      abilities: [CraftyStrike, LongInvincibility, NullifyingRampage, Sidestep]).reset_attributes!
    MinMaxStrategy.reset_cache
    result = MinMaxStrategy.next_move(attacker, defender)
    puts MinMaxStrategy.cache_stats
    assert_includes [Sidestep, CraftyStrike], result.class
  end

end
