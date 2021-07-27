require 'test_helper'

class MinMaxStrategyTest < ActiveSupport::TestCase

  test "MinMax Strategy should find strongest move even when there is no guarantee of a win" do
    #skip
    attacker = Dinosaur.new(
      value: 1.0,
      level: 26,
      health_26: 4500,
      damage_26: 1700,
      speed: 105,
      armor: 0,
      critical_chance: 40,
      name: 'Thoradolosaur',
      abilities: [FierceStrike, FierceImpact, GroupShatteringRampage, InstantCharge]).reset_attributes!
    defender = Dinosaur.new(
      value: -1.0,
      level: 26,
      health_26: 1650,
      damage_26: 1550,
      speed: 132,
      armor: 0,
      critical_chance: 5,
      name: 'Velociraptor',
      abilities: [Strike, HighPounce]).reset_attributes!

    result = MinMaxStrategy.next_move(attacker, defender)
    assert_equal FierceImpact, result.class
  end

  test "MinMax Strategy should find strongest move when there is a clear path to victory" do
    skip
    defender = Dinosaur.new(
      value: -1.0,
      level: 26,
      health_26: 4500,
      damage_26: 1700,
      speed: 105,
      armor: 0,
      critical_chance: 40,
      name: 'Thoradolosaur',
      abilities: [FierceStrike, FierceImpact, GroupShatteringRampage, InstantCharge]).reset_attributes!
    attacker = Dinosaur.new(
      value: 1.0,
      level: 26,
      health_26: 1650,
      damage_26: 1550,
      speed: 132,
      armor: 0,
      critical_chance: 5,
      name: 'Velociraptor',
      abilities: [Strike, HighPounce]).reset_attributes!

    result = MinMaxStrategy.next_move(attacker, defender)
    assert_equal HighPounce, result.class
  end

  test "MinMax Strategy should use damage over time" do
    skip
    attacker = Dinosaur.new(
      value: 1.0,
      level: 26,
      health_26: 4500,
      damage_26: 1300,
      speed: 116,
      armor: 0,
      critical_chance: 20,
      name: 'Suchotator',
      abilities: [SuperiorityStrike, LethalWound, NullifyingImpact, InstantDistraction]).reset_attributes!
    defender = Dinosaur.new(
      value: -1.0,
      level: 26,
      health_26: 1650,
      damage_26: 1550,
      speed: 132,
      armor: 0,
      critical_chance: 5,
      name: 'Velociraptor',
      abilities: [Strike, HighPounce]).reset_attributes!
      MinMaxStrategy.reset
    result = MinMaxStrategy.next_move(attacker, defender)
    assert_equal LethalWound, result.class

  end

  test "MinMax Strategy should find a good move for Quetzorion" do
    skip
    defender = Dinosaur.new(
      value: -1.0,
      level: 26,
      health_26: 4500,
      damage_26: 1700,
      speed: 105,
      armor: 0,
      critical_chance: 40,
      name: 'Thoradolosaur',
      abilities: [FierceStrike, FierceImpact, GroupShatteringRampage, InstantCharge]).reset_attributes!
    attacker = Dinosaur.new(
      value: 1.0,
      level: 26,
      health_26: 4200,
      damage_26: 1450,
      speed: 130,
      armor: 0,
      critical_chance: 20,
      name: 'Quetzorion',
      abilities: [CraftyStrike, LongInvincibility, NullifyingRampage, Sidestep]).reset_attributes!
    MinMaxStrategy.reset
    result = MinMaxStrategy.next_move(attacker, defender)
    puts MinMaxStrategy.stats
    assert_includes [Sidestep, CraftyStrike], result.class
  end

  test "should save state to disk and load back" do
    skip
    MinMaxStrategy.reset
    10.times do
      d1 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd1', abilities: [Strike, Impact], strategy: DefaultStrategy)
      d2 = Dinosaur.new(health_26: 1000, damage_26: 300, speed: 130, level: 20, name: 'd2', abilities: [Strike, Impact], strategy: MinMaxStrategy)
      match = Match.new(d1, d2)
      result = match.execute
      MinMaxStrategy.learn(result[:outcome_value])
    end
    MinMaxStrategy.save
    games_played = MinMaxStrategy.games_played
    MinMaxStrategy.reset
    assert_equal 0, MinMaxStrategy.games_played
    MinMaxStrategy.load
    assert_equal games_played, MinMaxStrategy.games_played
  end

  test "MinMax should find path to victory for GT over Thor" do
    skip
    MinMaxStrategy.reset
    attacker = Dinosaur.find_by_name('Geminititan').reset_attributes!
    defender = Dinosaur.find_by_name('Thoradolosaur').reset_attributes!
    attacker.strategy = MinMaxStrategy
    defender.strategy = HighestDamageStrategy
    attacker.value = 1.0
    defender.value = -1.0
    ability_attacker = attacker.strategy.next_move(attacker, defender)
    ability_defender = defender.strategy.next_move(defender, attacker)
    ability_attacker.execute(attacker, defender)
    ability_defender.execute(defender, attacker)
    attacker.tick
    defender.tick
    ability_attacker = attacker.strategy.next_move(attacker, defender)

    assert_equal "DefiniteShieldAdvantage", ability_attacker.class.name
  end
end
