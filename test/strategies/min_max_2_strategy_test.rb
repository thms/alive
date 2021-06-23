require 'test_helper'

class MinMax2StrategyTest < ActiveSupport::TestCase

  test "MinMax Strategy should find strongest move even when there is a clear path to victory as maximising player" do
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

    result = MinMax2Strategy.next_move(attacker, defender)
    assert_includes [FierceImpact, FierceStrike], result.class
  end

  test "MinMax Strategy should find path to vicory for maximising player" do
    dinosaur1 = Dinosaur.new(
      level: 26,
      health_26: 4500,
      damage_26: 1700,
      speed: 105,
      armor: 0,
      critical_chance: 40,
      name: 'Thoradolosaur',
      abilities: [FierceStrike, FierceImpact, GroupShatteringRampage, InstantCharge]).reset_attributes!
     dinosaur2 = Dinosaur.new(
      level: 26,
      health_26: 1650,
      damage_26: 1550,
      speed: 132,
      armor: 0,
      critical_chance: 5,
      name: 'Velociraptor',
      abilities: [Strike, HighPounce]).reset_attributes!
    dinosaur1.strategy = MinMax2Strategy
    dinosaur2.strategy = MinMaxStrategy
    result = Match.new(dinosaur1, dinosaur2).execute
    assert_equal 'Thoradolosaur', result[:outcome]
  end

  test "MinMax Strategy should find path to vicory for minimizing player" do
    dinosaur1 = Dinosaur.new(
      level: 26,
      health_26: 4500,
      damage_26: 1700,
      speed: 105,
      armor: 0,
      critical_chance: 40,
      name: 'Thoradolosaur',
      abilities: [FierceStrike, FierceImpact, GroupShatteringRampage, InstantCharge]).reset_attributes!
     dinosaur2 = Dinosaur.new(
      level: 26,
      health_26: 1650,
      damage_26: 1550,
      speed: 132,
      armor: 0,
      critical_chance: 5,
      name: 'Velociraptor',
      abilities: [Strike, HighPounce]).reset_attributes!
    dinosaur1.strategy = MinMax2Strategy
    dinosaur2.strategy = MinMaxStrategy
    result = Match.new(dinosaur2, dinosaur1).execute
    assert_equal 'Thoradolosaur', result[:outcome]
  end

  test "MinMax Strategy should find path to vicory for minimising player quetzorion" do
    dinosaur1 = Dinosaur.new(
      level: 26,
      health_26: 4500,
      damage_26: 1700,
      speed: 105,
      armor: 0,
      critical_chance: 40,
      name: 'Thoradolosaur',
      abilities: [FierceStrike, FierceImpact, GroupShatteringRampage, InstantCharge]).reset_attributes!
     dinosaur2 = Dinosaur.new(
      level: 26,
      health_26: 4200,
      damage_26: 1450,
      speed: 130,
      armor: 0,
      critical_chance: 20,
      name: 'Quetzorion',
      abilities: [CraftyStrike, LongInvincibility, NullifyingRampage, Sidestep],
      abilities_counter: [NullifyingCounter]
    ).reset_attributes!
    dinosaur1.strategy = MinMaxStrategy
    dinosaur2.strategy = MinMax2Strategy
    result = Match.new(dinosaur1, dinosaur2).execute
    assert_equal 'Thoradolosaur', result[:outcome]
  end

  test "MinMax Strategy should find strongest move when there is a clear path to victory" do
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

    result = MinMax2Strategy.next_move(attacker, defender)
    assert_equal HighPounce, result.class
  end

end
