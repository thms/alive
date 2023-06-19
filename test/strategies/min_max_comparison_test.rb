require 'test_helper'

class MinMaxComparisonTest < ActiveSupport::TestCase

  'One move away from victory'
  test "MinMax Strategy should find winning move if there is one" do
    attacker = Dinosaur.new(
      value: 1.0,
      level: 26,
      health_26: 1000,
      damage_26: 800,
      speed: 105,
      armor: 0,
      critical_chance: 0,
      name: 'Attacker',
      abilities: [Strike, Impact]).reset_attributes!
    defender = Dinosaur.new(
      value: -1.0,
      level: 26,
      health_26: 1000,
      damage_26: 800,
      speed: 104,
      armor: 0,
      critical_chance: 0,
      name: 'Defender',
      abilities: [Strike, Impact]).reset_attributes!

    MinMaxStrategy.reset
    result = MinMaxStrategy.next_move(attacker, defender)
    assert_equal Impact, result.class
    MinMaxStrategy.reset
    attacker.value = -1.0
    defender.value = 1.0
    result = MinMaxStrategy.next_move(attacker, defender)
    assert_equal Impact, result.class
  end

  test "MinMax2 Strategy should find winning move if there is one" do
    attacker = Dinosaur.new(
      value: 1.0,
      level: 26,
      health_26: 1000,
      damage_26: 800,
      speed: 105,
      armor: 0,
      critical_chance: 0,
      name: 'Attacker',
      abilities: [Strike, Impact]).reset_attributes!
    defender = Dinosaur.new(
      value: -1.0,
      level: 26,
      health_26: 1000,
      damage_26: 800,
      speed: 104,
      armor: 0,
      critical_chance: 0,
      name: 'Defender',
      abilities: [Strike, Impact]).reset_attributes!

    MinMax2Strategy.reset
    result = MinMax2Strategy.next_move(attacker, defender)
    assert_equal Impact, result.class
    attacker.value = -1.0
    defender.value = 1.0
    MinMax2Strategy.reset
    result = MinMax2Strategy.next_move(attacker, defender)
    assert_equal Impact, result.class
  end

  'defender two moves away from victory, but will loose if choosing badly'
  test "Defender two moves MinMax Strategy should find winning move" do
    attacker = Dinosaur.new(
      value: 1.0,
      level: 26,
      health_26: 1600,
      damage_26: 500,
      speed: 105,
      armor: 0,
      critical_chance: 0,
      name: 'Attacker',
      abilities: [CleansingStrike, Impact]).reset_attributes!
    defender = Dinosaur.new(
      value: -1.0,
      level: 26,
      health_26: 1600,
      damage_26: 500,
      speed: 104,
      armor: 0,
      critical_chance: 0,
      name: 'Defender',
      abilities: [Strike, DeceleratingImpact]).reset_attributes!

    MinMaxStrategy.reset
#    result = MinMaxStrategy.next_move(defender, attacker)
#    assert_equal Strike, result.class
    attacker.strategy = MinMaxStrategy
    defender.strategy = MinMaxStrategy
    match = Match.new(attacker, defender)
    result = match.execute
    pp result[:log]
    assert_equal 'Defender', result[:outcome]
  end

  'Defender two moves away from victory'
  test "Two moves MinMax2 Strategy should find winning move" do
    attacker = Dinosaur.new(
      value: 1.0,
      level: 26,
      health_26: 1600,
      damage_26: 500,
      speed: 105,
      armor: 0,
      critical_chance: 0,
      name: 'Attacker',
      abilities: [CleansingStrike, Impact]).reset_attributes!
    defender = Dinosaur.new(
      value: -1.0,
      level: 26,
      health_26: 1600,
      damage_26: 500,
      speed: 104,
      armor: 0,
      critical_chance: 0,
      name: 'Defender',
      abilities: [Strike, DeceleratingImpact]).reset_attributes!

    MinMax2Strategy.reset
    attacker.strategy = MinMax2Strategy
    defender.strategy = MinMax2Strategy
    match = Match.new(attacker, defender)
    result = match.execute
    pp result[:log]
    assert_equal 'Defender', result[:outcome]
  end

  
  test "MinMax Thyla vs Sarco should be symmetric, ie. use the same move no matter the initial order" do
    attacker = Dinosaur.find_by_name('Thylacotator').reset_attributes!
    attacker.value = 1.0
    defender = Dinosaur.find_by_name('Sarcorixis').reset_attributes!
    defender.value = -1.0
    MinMaxStrategy.reset
    result = MinMaxStrategy.next_move(attacker, defender)
    assert_equal MaimingWound, result.class

    attacker.value = -1.0
    defender.value = 1.0
    MinMaxStrategy.reset
    result = MinMaxStrategy.next_move(attacker, defender)
    assert_equal MaimingWound, result.class
  end

  
  test "MinMax2 Thyla vs Sarco should be symmetric" do
    attacker = Dinosaur.find_by_name('Thylacotator').reset_attributes!
    attacker.value = 1.0
    defender = Dinosaur.find_by_name('Sarcorixis').reset_attributes!
    defender.value = -1.0
    MinMax2Strategy.reset
    result = MinMax2Strategy.next_move(attacker, defender)
    #assert_equal MaimingWound, result.class

    # attacker.value = -1.0
    # defender.value = 1.0
    # MinMax2Strategy.reset
    # result = MinMax2Strategy.next_move(attacker, defender)
    # assert_equal MaimingWound, result.class
  end

  test "MinMax Erlikospyx vs Erlidominus" do
    # if  Erlikospyx has 100% critical chance it will always win if using PrecisePounce
    attacker = Dinosaur.find_by_name('Erlikospyx').reset_attributes!
    attacker.value = 1.0
    attacker.critical_chance = 100
    defender = Dinosaur.find_by_name('Erlidominus').reset_attributes!
    defender.value = -1.0
    MinMaxStrategy.reset
    result = MinMaxStrategy.next_move(attacker, defender)
    assert_equal PrecisePounce, result.class
  end

end
